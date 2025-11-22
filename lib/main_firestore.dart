import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'src/app_constants.dart';
import 'models/user.dart';
import 'src/app_colors.dart';
import 'services/localization_service.dart';
import 'src/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ThemeService.loadTheme(); // Carga la preferencia de tema guardada

  const useEmulator = bool.fromEnvironment('USE_EMULATOR', defaultValue: false);
  if (useEmulator) {
    try {}
    catch (_) {}
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocalizationService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationService = context.watch<LocalizationService>();

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'UrbanSafe',
          locale: localizationService.currentLocale,
          supportedLocales: const [Locale('es'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          themeMode: currentMode,
          theme: ThemeData(
            colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: AppColors.primary,
              onPrimary: Colors.white,
              secondary: AppColors.secondary,
              onSecondary: Colors.white,
              error: AppColors.error,
              onError: Colors.white,
              surface: AppColors.background,
              onSurface: AppColors.tertiary,
            ),
            scaffoldBackgroundColor: AppColors.background,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: const ColorScheme(
              brightness: Brightness.dark,
              primary: AppColors.primary,
              onPrimary: Colors.white,
              secondary: AppColors.secondary,
              onSecondary: Colors.white,
              error: AppColors.error,
              onError: Colors.white,
              surface: AppColors.tertiary,
              onSurface: Colors.white,
            ),
            scaffoldBackgroundColor: AppColors.tertiary,
            useMaterial3: true,
          ),
          home: const _SessionRestorer(),
        );
      },
    );
  }
}

/// Widget que restaura la sesión del usuario si es posible.
class _SessionRestorer extends StatefulWidget {
  const _SessionRestorer();

  @override
  State<_SessionRestorer> createState() => _SessionRestorerState();
}

/// Estado del [_SessionRestorer] que maneja la lógica de restauración de sesión.
class _SessionRestorerState extends State<_SessionRestorer> {
  Future<Widget> _determineStart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(kSessionUserIdKey);
      final token = prefs.getString(kSessionTokenKey);
      if (userId == null || userId.isEmpty || token == null || token.isEmpty) {
        return const LoginPage();
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!doc.exists) return const LoginPage();
      final data = doc.data();
      final serverToken = data?['sessionToken'] as String?;
      final expiryTs = data?['sessionTokenExpiry'];
      DateTime? expiry;
      if (expiryTs is Timestamp) {
        expiry = expiryTs.toDate().toUtc();
      } else if (expiryTs is Map && expiryTs['seconds'] != null) {
        try {
          final seconds = expiryTs['seconds'] as int;
          expiry = DateTime.fromMillisecondsSinceEpoch(seconds * 1000).toUtc();
        } catch (_) {}
      }

      final now = DateTime.now().toUtc();
      if (serverToken != null && serverToken == token && expiry != null && now.isBefore(expiry)) {
        final user = User.fromDoc(doc);
        return HomePage(user: user);
      }
    } catch (_) {}
    return const LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _determineStart(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snap.data ?? const LoginPage();
      },
    );
  }
}
