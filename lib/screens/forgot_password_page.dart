import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/password_recovery_service.dart';
import '../src/app_translations.dart';
import '../services/localization_service.dart';
import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final PasswordRecoveryService _recoveryService = PasswordRecoveryService();
  String? _error;
  String? _success;
  bool _loading = false;

  Future<void> _sendRecoveryCode(String lang) async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _error = AppTranslations.get('email_required', lang));
      return;
    }

    setState(() {
      _error = null;
      _success = null;
      _loading = true;
    });

    try {
      final code = await _recoveryService.sendRecoveryCode(email);

      if (!mounted) return;

      if (code != null) {
        setState(() {
          _success = AppTranslations.get('recovery_code_sent', lang);
          _error = null;
        });

        // Navigate to reset password page after 1 second and show the code
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) =>
                  ResetPasswordPage(email: email, displayCode: code),
            ),
          );
        }
      } else {
        setState(() => _error = AppTranslations.get('email_not_found', lang));
      }
    } catch (e) {
      setState(() => _error = '${AppTranslations.get('error', lang)}: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();
    final lang = localization.currentLanguageCode;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.get('forgot_password', lang))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                AppTranslations.get('recovery_instructions', lang),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: AppTranslations.get('email', lang),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                      width: 1.0,
                    ),
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
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    _error!,
                    style: TextStyle(color: colorScheme.error, fontSize: 14),
                  ),
                ),
              if (_success != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    _success!,
                    style: const TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 20),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _sendRecoveryCode(lang),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          AppTranslations.get('send_recovery_code', lang),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppTranslations.get('back', lang),
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
