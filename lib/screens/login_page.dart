import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import '../src/app_constants.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../src/auth/hash.dart';
import 'register_page.dart';
import 'home_page.dart';

/// Página de inicio de sesión de usuarios existentes.
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

  Future<void> _loginWithFirestore() async {
    final email = _userController.text.trim();
    final password = _passController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = (email.isEmpty && password.isEmpty)
            ? 'Ingresa correo y contraseña'
            : (email.isEmpty
                  ? 'Ingresa tu correo electrónico'
                  : 'Ingresa tu contraseña');
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
        setState(() => _error = 'No existe una cuenta con ese correo.');
        return;
      }

      final doc = q.docs.first;
      final user = User.fromDoc(doc);

      final storedHash = user.passwordHash;
      if (storedHash == null) {
        setState(
          () => _error =
              'Cuenta encontrada pero sin contraseña almacenada. Contacta al administrador.',
        );
        return;
      }

      final inputHash = hashPassword(password, email);
      if (inputHash != storedHash) {
        setState(() => _error = 'Contraseña incorrecta.');
        return;
      }

      if (!mounted) return;
      final token =
          '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1 << 32)}';
      final expiry = DateTime.now().toUtc().add(
        Duration(minutes: kSessionTokenTtlMinutes),
      );
      try {
        // Persistir token de sesión en Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .update({
              'sessionToken': token,
              'sessionTokenExpiry': Timestamp.fromDate(expiry),
            });
      } catch (e) {
        // Persistir token de sesión en Firestore falló
      }

      // Persistir localmente (solo necesitamos el token y el id de usuario)
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(kSessionUserIdKey, user.id ?? '');
        await prefs.setString(kSessionTokenKey, token);
      } catch (e) {
        // Persistir localmente falló
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage(user: user)),
      );
    } on FirebaseException catch (fe) {
      setState(
        () => _error = 'Error al acceder a Firestore: ${fe.message ?? fe.code}',
      );
    } catch (e) {
      setState(() => _error = 'Error al iniciar sesión: $e');
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
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: 'Correo',
                hintText: 'usuario@dominio.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _loginWithFirestore,
                    child: const Text('Entrar'),
                  ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const RegisterPage())),
              child: const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
