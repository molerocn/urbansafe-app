import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../src/auth/hash.dart';

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

  Future<void> _registerFirestore() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final nombre = _nameController.text.trim();
    final correo = _emailController.text.trim();
    final contrasena = _passwordController.text;

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final q = await FirebaseFirestore.instance
          .collection('users')
          .where('correo', isEqualTo: correo)
          .limit(1)
          .get();

      if (q.docs.isNotEmpty) {
        setState(() => _error = 'Ya existe una cuenta con ese correo.');
        return;
      }

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

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro exitoso. Ahora puedes iniciar sesión.'),
        ),
      );
      // Volver a la pantalla de login
      Navigator.of(context).pop();
    } on FirebaseException catch (fe) {
      setState(
        () => _error =
            'Error al guardar perfil en Firestore: ${fe.message ?? fe.code}',
      );
    } catch (e) {
      setState(() => _error = 'Error al registrar: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa tu nombre'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Ingresa un correo';
                  }
                  final emailReg = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
                  if (!emailReg.hasMatch(v.trim())) {
                    return 'Correo inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Ingresa una contraseña';
                  }
                  if (v.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar contraseña',
                ),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Confirma la contraseña';
                  }
                  if (v != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _registerFirestore,
                      child: const Text('Registrar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
