import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../src/app_colors.dart';
import '../src/auth/hash.dart';
import '../src/app_constants.dart';
import '../src/app_translations.dart';
import '../services/localization_service.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'forgot_password_page.dart';

/// Página de inicio de sesión (UI similar a la del registro)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _loginWithFirestore(String lang) async {
    final email = _userController.text.trim();
    final password = _passController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = (email.isEmpty && password.isEmpty)
            ? AppTranslations.get('email_password_required', lang)
            : (email.isEmpty
                  ? AppTranslations.get('email_required', lang)
                  : AppTranslations.get('password_required', lang));
      });
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final q = await FirebaseFirestore.instance
          .collection('users')
          .where('correo', isEqualTo: email)
          .limit(1)
          .get();

      if (q.docs.isEmpty) {
        setState(() => _error = AppTranslations.get('no_account_found', lang));
        return;
      }

      final doc = q.docs.first;
      final user = User.fromDoc(doc);

      final storedHash = user.passwordHash;
      if (storedHash == null) {
        setState(
          () => _error = AppTranslations.get('account_without_password', lang),
        );
        return;
      }

      final inputHash = hashPassword(password, email);
      if (inputHash != storedHash) {
        setState(
          () => _error = AppTranslations.get('incorrect_password', lang),
        );
        return;
      }

      final token =
          '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1 << 32)}';
      final expiry = DateTime.now().toUtc().add(
        Duration(minutes: kSessionTokenTtlMinutes),
      );

      await FirebaseFirestore.instance.collection('users').doc(user.id).update({
        'sessionToken': token,
        'sessionTokenExpiry': Timestamp.fromDate(expiry),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kSessionUserIdKey, user.id ?? '');
      await prefs.setString(kSessionTokenKey, token);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage(user: user)),
      );
    } catch (e) {
      setState(
        () => _error = '${AppTranslations.get('login_error', lang)}: $e',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();
    final lang = localization.currentLanguageCode;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Imagen superior (sin cambios)
            Stack(
              children: [
                Image.asset(
                  'lib/assets/images/callafondo.jpeg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.black.withOpacity(0.45),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppTranslations.get('app_title', lang),
                          style: const TextStyle(
                            color: AppColors.background, // Dorado
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lang == 'es'
                              ? "prioriza tu seguridad"
                              : "prioritize your safety",
                          style: const TextStyle(
                            color: AppColors.background, // Dorado
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Campo correo
                  _buildField(
                    context: context,
                    controller: _userController,
                    label: AppTranslations.get('email', lang),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Campo contraseña
                  _buildField(
                    context: context,
                    controller: _passController,
                    label: AppTranslations.get('password', lang),
                    obscureText: true,
                  ),

                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                         Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(AppTranslations.get('forgot_password', lang)),
                    ),
                  ),

                  if (_error != null)
                    Text(_error!, style: TextStyle(color: colorScheme.error)),

                  const SizedBox(height: 20),

                  // Botón principal
                  _loading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _loginWithFirestore(lang),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              AppTranslations.get('login_button', lang),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(height: 20),
                  const Text("o"),
                  const SizedBox(height: 20),

                  // Botón Google
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: Image.asset(
                        'lib/assets/images/iconogoo.png',
                        height: 20,
                      ),
                      label: Text(
                        AppTranslations.get('google_signin', lang),
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: colorScheme.surfaceVariant,
                      ),
                      onPressed: _signInWithGoogle,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Texto de registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(lang == 'es' ? 'No tienes una cuenta?' : 'Don\'t have an account?'),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          lang == 'es' ? ' Regístrate aquí' : ' Register here',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Botón de cambiar idioma
                  Tooltip(
                    message: AppTranslations.get('change_language', lang),
                    child: TextButton.icon(
                      onPressed: () async {
                        await localization.toggleLanguage();
                      },
                      icon: const Icon(Icons.language, size: 20),
                      label: Text(
                        localization.getOtherLanguageName(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
           borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withAlpha((0.5 * 255).round()),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    // Mantiene tu lógica actual sin modificar
    try {
      final GoogleSignInAccount? account = await GoogleSignIn().signIn();
      if (account == null) return;
      final googleAuth = await account.authentication;
      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await fb_auth.FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final email = userCred.user?.email;
      final displayName = userCred.user?.displayName ?? '';
      if (email == null || email.isEmpty) return;

      final q = await FirebaseFirestore.instance
          .collection('users')
          .where('correo', isEqualTo: email)
          .limit(1)
          .get();

      DocumentSnapshot doc;
      if (q.docs.isNotEmpty) {
        doc = q.docs.first;
      } else {
        final newUserMap = {
          'nombre': displayName,
          'correo': email,
          'rol': 'Usuario',
          'createdAt': FieldValue.serverTimestamp(),
        };
        final ref = await FirebaseFirestore.instance
            .collection('users')
            .add(newUserMap);
        doc = await ref.get();
      }

      final user = User.fromDoc(doc);
      final token =
          '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1 << 32)}';
      final expiry = DateTime.now().toUtc().add(
        Duration(minutes: kSessionTokenTtlMinutes),
      );
      await FirebaseFirestore.instance.collection('users').doc(user.id).update({
        'sessionToken': token,
        'sessionTokenExpiry': Timestamp.fromDate(expiry),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kSessionUserIdKey, user.id ?? '');
      await prefs.setString(kSessionTokenKey, token);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage(user: user)),
      );
    } catch (_) {}
  }
}
