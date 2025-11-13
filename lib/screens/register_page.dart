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
        setState(() => _error = 'Ya existe una cuenta con ese correo.');
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
        const SnackBar(
          content: Text('Registro exitoso. Ahora puedes iniciar sesión.'),
        ),
      );
      Navigator.of(context).pop();
    } on FirebaseException catch (fe) {
      setState(
        () =>
            _error = 'Error al guardar en Firestore: ${fe.message ?? fe.code}',
      );
    } catch (e) {
      setState(() => _error = 'Error al registrar: $e');
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 
            Stack(
              children: [
                // Imagen de fondo
                Image.asset(
                  'lib/assets/images/callafondo.jpeg', // asegúrate de tenerlo en assets/images
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
                        Colors.black.withOpacity(0.45),
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
                      children: const [
                        Text(
                          "URBANSAFE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "prioriza tu seguridad",
                          style: TextStyle(
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
                    _buildField(controller: _nameController, label: 'Nombre'),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _emailController,
                      label: 'Correo electrónico',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Ingresa un correo';
                        }
                        final emailReg = RegExp(
                          r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                        );
                        if (!emailReg.hasMatch(v.trim())) {
                          return 'Correo inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _passwordController,
                      label: 'Contraseña',
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Ingresa una contraseña';
                        }
                        if (v.length < 6) {
                          return 'Debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _confirmPasswordController,
                      label: 'Confirmar contraseña',
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
                    const SizedBox(height: 24),

                    if (_error != null)
                      Text(_error!, style: const TextStyle(color: Colors.red)),

                    const SizedBox(height: 16),

                    // Boton de register
                    _loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _registerFirestore,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Registrarme',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
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
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
