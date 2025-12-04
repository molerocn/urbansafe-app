import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/risk_measurement.dart';
import '../models/user.dart';
import '../repositories/measurement_repository.dart';
import '../services/export_service.dart';
import '../services/localization_service.dart';
import '../src/app_translations.dart';
import '../src/app_colors.dart';
import 'history_map_page.dart'; // Importa la nueva página del mapa

/// Página que muestra el historial de mediciones de riesgo de un usuario.
class MeasurementsHistoryPage extends StatefulWidget {
  final User user;

  const MeasurementsHistoryPage({super.key, required this.user});

  @override
  State<MeasurementsHistoryPage> createState() =>
      _MeasurementsHistoryPageState();
}

class _MeasurementsHistoryPageState extends State<MeasurementsHistoryPage> {
  final MedicionRepository _repo = MedicionRepository();
  final List<RiskMeasurement> _items = [];
  DocumentSnapshot? _lastDoc;
  bool _loading = false;
  bool _hasMore = true;
  final int _pageSize = 12;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  // Devuelve un ícono representativo del nivel de riesgo de la medición.
  Icon _iconForMedicion(RiskMeasurement m) {
    final label = (m.nivelRiesgoLabel ?? '').toLowerCase();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (label.contains('alto')) {
      return Icon(Icons.warning, color: colorScheme.error);
    }
    if (label.contains('bajo')) {
      return Icon(Icons.check_circle, color: isDark ? Colors.green : colorScheme.primary);
    }
    // fallback based on numeric
    final v = m.nivelRiesgo;
    if (v >= 2.5) {
      return Icon(Icons.warning, color: colorScheme.error);
    }
    return Icon(Icons.check_circle, color: isDark ? Colors.green : colorScheme.primary);
  }

  // Formatea la fecha de la medición para mostrarla en la lista.
  String _formatDate(Timestamp? ts, String languageCode) {
    if (ts == null) return AppTranslations.get('date', languageCode);
    final dt = ts.toDate();
    final pattern = AppTranslations.get('date_format', languageCode);
    return DateFormat(pattern).format(dt);
  }

  // Carga una página de mediciones desde Firestore.
  Future<void> _loadPage() async {
    if (_loading || !_hasMore) return;
    final uid = widget.user.id;
    if (uid == null) return;
    setState(() => _loading = true);
    try {
      final snap = await _repo.getMedicionesPageForUser(
        uid,
        limit: _pageSize,
        startAfter: _lastDoc,
      );
      final docs = snap.docs;
      if (docs.isEmpty) {
        _hasMore = false;
      } else {
        final pageItems = docs.map((d) => RiskMeasurement.fromDoc(d)).toList();
        _items.addAll(pageItems);
        _lastDoc = docs.last;
        if (docs.length < _pageSize) _hasMore = false;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando página de mediciones: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Exporta el historial a CSV
  Future<void> _exportToCSV(String lang) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.get('loading', lang)), backgroundColor: Theme.of(context).colorScheme.surfaceVariant),
      );

      final filePath = await ExportService.exportToCSV(_items);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.get('export_success', lang)),
            backgroundColor: Theme.of(context).colorScheme.primary,
            action: SnackBarAction(
              label: AppTranslations.get('share_button', lang),
              onPressed: () => ExportService.shareFile(filePath),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppTranslations.get('export_error', lang)}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // Exporta el historial a PDF
  Future<void> _exportToPDF(String lang) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.get('loading', lang)), backgroundColor: Theme.of(context).colorScheme.surfaceVariant),
      );

      final filePath = await ExportService.exportToPDF(_items);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.get('export_success', lang)),
            backgroundColor: Theme.of(context).colorScheme.primary,
            action: SnackBarAction(
              label: AppTranslations.get('share_button', lang),
              onPressed: () => ExportService.shareFile(filePath),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppTranslations.get('export_error', lang)}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // Construye la interfaz de usuario para la página de historial de mediciones.
  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();
    final lang = localization.currentLanguageCode;
    final colorScheme = Theme.of(context).colorScheme;
    final uid = widget.user.id;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppTranslations.get('history_title', lang))),
        body: Center(child: Text(AppTranslations.get('welcome', lang))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.get('history_title', lang), style: TextStyle(color: AppColors.secondary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_items.isNotEmpty) // Solo muestra el botón si hay mediciones
            IconButton(
              icon: Icon(Icons.map_outlined, color: colorScheme.onPrimary),
              tooltip: 'Ver en mapa', // TODO: Internacionalizar
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HistoryMapPage(measurements: _items),
                  ),
                );
              },
            ),
        ],
      ),
      body: _items.isEmpty && _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Barra de herramientas de exportación
                if (_items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _exportToCSV(lang),
                          icon: Icon(Icons.file_download, color: colorScheme.onSurface),
                          label: Text(AppTranslations.get('export_csv', lang), style: TextStyle(color: colorScheme.onSurface)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _exportToPDF(lang),
                          icon: Icon(Icons.picture_as_pdf, color: colorScheme.onSurface),
                          label: Text('PDF', style: TextStyle(color: colorScheme.onSurface)),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _items.isEmpty
                      ? Center(
                          child: Text(
                            AppTranslations.get('no_measurements', lang),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final m = _items[index];
                            final rawLabel = m.nivelRiesgoLabel ?? m.nivelRiesgo.toString();
                            String displayLabel = AppTranslations.get('risk_unknown', lang);
                            if (rawLabel.toLowerCase().contains('alto')) {
                              displayLabel = AppTranslations.get('risk_high', lang);
                            } else if (rawLabel.toLowerCase().contains('bajo')) {
                              displayLabel = AppTranslations.get('risk_low', lang);
                            }
                            return ListTile(
                              leading: _iconForMedicion(m),
                              title: Text(displayLabel),
                              subtitle: Text(_formatDate(m.fecha, lang)),
                              trailing: Text(m.user?['nombre'] ?? ''),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(
                                      '${AppTranslations.get('risk_level', lang)} - $displayLabel',
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${AppTranslations.get('risk_level', lang)}: $displayLabel',
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${AppTranslations.get('date', lang)}: ${_formatDate(m.fecha, lang)}',
                                        ),
                                        if (m.ubicacionLat != null &&
                                            m.ubicacionLng != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            '${AppTranslations.get('location', lang)}: ${m.ubicacionLat}, ${m.ubicacionLng}',
                                          ),
                                        ],
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          AppTranslations.get('close', lang),
                                          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
                if (_hasMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _loadPage,
                            child: Text(AppTranslations.get('load_more', lang), style: TextStyle(color: colorScheme.onSurface)),
                          ),
                  ),
              ],
            ),
    );
  }
}
