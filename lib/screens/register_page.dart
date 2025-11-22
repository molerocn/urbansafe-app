import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../src/auth/hash.dart';
import '../src/app_translations.dart';
import '../services/localization_service.dart';

/// Página de registro de nuevos usuarios.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _registerFirestore(String lang) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final nombre = _nameController.text.trim();
    final correo = _emailController.text.trim();
    final contrasena = _passwordController.text;

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      // Verificar si ya existe el correo
      final q = await FirebaseFirestore.instance
          .collection('users')
          .where('correo', isEqualTo: correo)
          .limit(1)
          .get();

      if (q.docs.isNotEmpty) {
        setState(() => _error = AppTranslations.get('account_exists', lang));
        return;
      }

      // Hashear contraseña y crear usuario
      final passwordHash = hashPassword(contrasena, correo);
      final newUser = User(
        nombre: nombre,
        correo: correo,
        rol: 'Usuario',
        passwordHash: passwordHash,
      );

      final map = newUser.toJson();
      map['createdAt'] = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance.collection('users').add(map);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.get('registration_success', lang)),
        ),
      );
      Navigator.of(context).pop();
    } on FirebaseException catch (fe) {
      setState(
        () => _error =
            '${AppTranslations.get('registration_error', lang)}: ${fe.message ?? fe.code}',
      );
    } catch (e) {
      setState(
        () => _error = '${AppTranslations.get('registration_error', lang)}: $e',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();
    final lang = localization.currentLanguageCode;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //
            Stack(
              children: [
                // Imagen de fondo
                Image.asset(
                  'lib/assets/images/callafondo.jpeg',
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),

                // Opacidad de la imagen
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Texto centrado
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppTranslations.get('app_title', lang),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          lang == 'es'
                              ? "prioriza tu seguridad"
                              : "prioritize your safety",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            //
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    _buildField(
                      controller: _nameController,
                      label: AppTranslations.get('full_name', lang),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? AppTranslations.get('name_required', lang)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _emailController,
                      label: AppTranslations.get('email', lang),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return AppTranslations.get('email_required', lang);
                        }
                        final emailReg = RegExp(
                          r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                        );
                        if (!emailReg.hasMatch(v.trim())) {
                          return AppTranslations.get('email_invalid', lang);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _passwordController,
                      label: AppTranslations.get('password', lang),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return AppTranslations.get('password_required', lang);
                        }
                        if (v.length < 6) {
                          return AppTranslations.get('password_short', lang);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _confirmPasswordController,
                      label: lang == 'es'
                          ? 'Confirmar contraseña'
                          : 'Confirm Password',
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return lang == 'es'
                              ? 'Confirma la contraseña'
                              : 'Confirm your password';
                        }
                        if (v != _passwordController.text) {
                          return lang == 'es'
                              ? 'Las contraseñas no coinciden'
                              : 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    if (_error != null)
                      Text(_error!, style: TextStyle(color: colorScheme.error)),

                    const SizedBox(height: 16),

                    // Boton de register
                    _loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _registerFirestore(lang),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                AppTranslations.get('register_button', lang),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),

                    const SizedBox(height: 30),

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

                    const SizedBox(height: 20),

                    // Texto de login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppTranslations.get('already_have_account', lang)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            AppTranslations.get('login_button', lang),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator:
          validator ??
          (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
