import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';

import '../models/user.dart';
import '../models/risk_measurement.dart';
import '../repositories/measurement_repository.dart';
import '../src/app_logger.dart';
import '../src/app_constants.dart';
import '../src/app_translations.dart';
import '../services/localization_service.dart';
import 'measurements_history_page.dart';
import 'login_page.dart';

// Página principal que muestra el nivel de riesgo actual y opciones de usuario.
class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _screenshotKey = GlobalKey();
  final MedicionRepository _repo = MedicionRepository();
  bool _saved = false;
  bool _loading = false;
  Timer? _loadingTimer;
  bool _loadingShown = false;
  String _riskLabel = '';
  double _riskValue = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPredictAndSave());
  }

  double _mapLabelToValue(String label) {
    final s = label.toLowerCase();
    if (s.contains('muy') && s.contains('alta')) {
      return 4.0;
    }
    if (s.contains('alta')) {
      return 3.0;
    }
    if (s.contains('media')) {
      return 2.0;
    }
    if (s.contains('baja')) {
      return 1.0;
    }
    return 0.0;
  }

  // Devuelve una descripción del nivel de riesgo basado en la etiqueta.
  String _mapLabelToDescription(String label, String languageCode) {
    final s = label.toLowerCase();
    if (s.contains('muy') && s.contains('alta')) {
      return AppTranslations.get('risk_description_very_high', languageCode);
    }
    if (s.contains('alta')) {
      return AppTranslations.get('risk_description_high', languageCode);
    }
    if (s.contains('media')) {
      return AppTranslations.get('risk_description_medium', languageCode);
    }
    if (s.contains('baja')) {
      return AppTranslations.get('risk_description_low', languageCode);
    }
    return AppTranslations.get('risk_description_unknown', languageCode);
  }

  Future<void> _fetchPredictAndSave() async {
    if (_saved) return;
    _saved = true;

    // Mostrar el indicador de carga si la operación tarda más de un corto retraso
    _loadingShown = false;
    _loadingTimer = Timer(const Duration(milliseconds: 75), () {
      _loadingShown = true;
      if (mounted) setState(() => _loading = true);
    });

    double? lat;
    double? lng;

    String label = 'Desconocido';
    double value = 0.0;

    try {
      try {
        final prefs = await SharedPreferences.getInstance();
        final askedKey = kLocationPermissionRequestedKey;
        final askedBefore = prefs.getBool(askedKey) ?? false;

        var permission = await Geolocator.checkPermission();
        appLog(
          'Location permission before request: $permission, askedBefore=$askedBefore',
          tag: 'location',
        );

        if (!askedBefore &&
            !(permission == LocationPermission.always ||
                permission == LocationPermission.whileInUse)) {
          final requested = await Geolocator.requestPermission();
          await prefs.setBool(askedKey, true);
          permission = requested;
          appLog(
            'Location permission after request: $permission',
            tag: 'location',
          );
        }

        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          try {
            final pos = await Geolocator.getCurrentPosition(
              timeLimit: const Duration(seconds: 5),
            );
            lat = pos.latitude;
            lng = pos.longitude;
            appLog('Got current position: $lat, $lng', tag: 'location');
          } catch (e) {
            appLog('Failed to get current position: $e', tag: 'location');
          }
        } else {
          appLog(
            'Location permission not granted: $permission',
            tag: 'location',
          );
        }
      } catch (e) {
        appLog('Error while obtaining location: $e', tag: 'location');
      }

      // Construir payload
      final payload = <String, dynamic>{'lat': lat, 'lng': lng};

      Map<String, dynamic>? apiResult;

      try {
        // Llamar a la API de predicción
        // primero /predict/risk, si falla /predict
        final uri1 = Uri.parse('$kPredictApiBase$kPredictRiskPath');
        final uri2 = Uri.parse('$kPredictApiBase$kPredictPath');

        String? idToken;
        try {
          idToken = await fb_auth.FirebaseAuth.instance.currentUser
              ?.getIdToken();
        } catch (e) {
          appLog('Could not obtain Firebase ID token: $e', tag: 'predict');
        }

        final headers = <String, String>{'Content-Type': 'application/json'};
        if (idToken != null && idToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $idToken';
        }

        http.Response resp = await http
            .post(uri1, headers: headers, body: jsonEncode(payload))
            .timeout(const Duration(seconds: 6));
        if (resp.statusCode == 404) {
          resp = await http
              .post(uri2, headers: headers, body: jsonEncode(payload))
              .timeout(const Duration(seconds: 6));
        }

        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          apiResult = jsonDecode(resp.body) as Map<String, dynamic>;
        } else {
          appLog(
            'Prediction API returned ${resp.statusCode}: ${resp.body}',
            tag: 'predict',
          );
        }
      } catch (e) {
        appLog('Error calling prediction API: $e', tag: 'predict');
      }

      if (apiResult != null) {
        try {
          final s = apiResult['score'];
          final l = apiResult['label'];
          if (s is num) value = s.toDouble();
          if (l is String) label = l;
        } catch (e) {
          appLog('Failed parsing API result: $e', tag: 'predict');
        }
      } else {
        // Valor predeterminado cuando falla la API
        label = 'Muy alta';
        value = _mapLabelToValue(label);
      }

      final medicion = RiskMeasurement(
        nivelRiesgo: value,
        nivelRiesgoLabel: label,
        ubicacionLat: lat,
        ubicacionLng: lng,
      );

      try {
        await _repo.createMedicionForUser(
          user: widget.user,
          medicion: medicion,
        );
        appLog(
          'Medición inicial guardada para usuario ${widget.user.id}',
          tag: 'medicion',
        );
      } catch (e) {
        appLog('Error guardando medición inicial: $e', tag: 'medicion');
      }
    } finally {
      _loadingTimer?.cancel();
      _loadingTimer = null;
      if (mounted) {
        if (_loadingShown) {
          setState(() {
            _loading = false;
            _riskLabel = label;
            _riskValue = value;
          });
        } else {
          setState(() {
            _riskLabel = label;
            _riskValue = value;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();
    final lang = localization.currentLanguageCode;
    final name = widget.user.nombre.isNotEmpty
        ? widget.user.nombre
        : AppTranslations.get('welcome', lang);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.get('app_title', lang)),
        actions: [
          IconButton(
            tooltip: AppTranslations.get('change_language', lang),
            icon: const Icon(Icons.language),
            onPressed: () async {
              await localization.toggleLanguage();
            },
          ),
          IconButton(
            tooltip: AppTranslations.get('history', lang),
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MeasurementsHistoryPage(user: widget.user),
                ),
              );
            },
          ),
          IconButton(
            tooltip: AppTranslations.get('logout', lang),
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(kSessionUserIdKey);
                await prefs.remove(kSessionTokenKey);
              } catch (e) {
                appLog(
                  'Failed clearing local session prefs: $e',
                  tag: 'session',
                );
              }

              try {
                final doc = FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.user.id);
                await doc.update({
                  'sessionToken': FieldValue.delete(),
                  'sessionTokenExpiry': FieldValue.delete(),
                });
              } catch (e) {
                appLog(
                  'Failed clearing sessionToken on Firestore: $e',
                  tag: 'session',
                );
              }

              try {
                await fb_auth.FirebaseAuth.instance.signOut();
              } catch (_) {}

              if (!mounted) return;
              navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${AppTranslations.get('welcome_message', lang)}$name',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: _loading
                    ? const CircularProgressIndicator()
                    : RepaintBoundary(
                        key: _screenshotKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _riskLabel.isNotEmpty
                                  ? _riskLabel
                                  : AppTranslations.get('risk_very_high', lang),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40.0,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _riskLabel.isNotEmpty
                                        ? _mapLabelToDescription(
                                            _riskLabel,
                                            lang,
                                          )
                                        : AppTranslations.get(
                                            'risk_description_very_high',
                                            lang,
                                          ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  if (_riskValue > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        '${AppTranslations.get('score', lang)}: ${_riskValue.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black45,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showEmergencyNumbers(context, lang),
                        icon: const Icon(Icons.call, size: 28),
                      ),
                      const SizedBox(height: 6),
                      Text(AppTranslations.get('emergency_numbers', lang)),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showShareModal(context, lang),
                        icon: const Icon(Icons.share, size: 28),
                      ),
                      const SizedBox(height: 6),
                      Text(AppTranslations.get('share_screenshot', lang)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<File?> _captureAndSavePng() async {
    try {
      final boundary =
          _screenshotKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      final ui.Image image = await boundary.toImage(
        pixelRatio: view.devicePixelRatio,
      );
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return null;
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);
      return file;
    } catch (e) {
      // ignore: avoid_print
      print('Error capturing screenshot: $e');
      return null;
    }
  }

  void _showShareModal(BuildContext context, String lang) async {
    final file = await _captureAndSavePng();
    if (file == null) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.get('screenshot_failed', lang)),
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    // ignore: use_build_context_synchronously
    showModalBottomSheet<void>(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                AppTranslations.get('share_screenshot', lang),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.file(file, height: 240),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    // ignore: deprecated_member_use
                    await Share.shareXFiles(
                      [XFile(file.path)],
                      text:
                          '${AppTranslations.get('risk_level', lang)}: $_riskLabel\n${AppTranslations.get('score', lang)}: ${_riskValue.toStringAsFixed(2)}',
                    );
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.share),
                  label: Text(AppTranslations.get('share_button', lang)),
                ),
                TextButton(
                  onPressed: () {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  },
                  child: Text(AppTranslations.get('close', lang)),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEmergencyNumbers(BuildContext context, String lang) {
    final numbers = <Map<String, String>>[
      {
        'label': AppTranslations.get('serenazgo', lang),
        'number': '+51123456789',
      },
      {
        'label': AppTranslations.get('ambulance', lang),
        'number': '+51123456790',
      },
      {'label': AppTranslations.get('police', lang), 'number': '+51123456791'},
    ];

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                AppTranslations.get('emergency_numbers', lang),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...numbers.map(
              (item) => ListTile(
                leading: const Icon(Icons.phone),
                title: Text(item['label'] ?? ''),
                subtitle: Text(item['number'] ?? ''),
                onTap: () {
                  final num = item['number'] ?? '';
                  _launchPhone(num);
                },
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppTranslations.get('close', lang)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (!await launchUrl(uri)) {
      // ignore: avoid_print
      print('No se pudo abrir el marcador para $phoneNumber');
    }
  }
}
