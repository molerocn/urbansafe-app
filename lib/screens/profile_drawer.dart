import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../models/user.dart';
import '../src/app_constants.dart';
import '../src/app_logger.dart';
import '../src/app_translations.dart';
import '../services/localization_service.dart';
import '../src/theme_service.dart';
import 'login_page.dart';

/// Un Drawer que muestra el perfil del usuario y permite editarlo.
class ProfileDrawer extends StatefulWidget {
  final User user;
  final Function(User) onProfileUpdated;

  const ProfileDrawer({super.key, required this.user, required this.onProfileUpdated});

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  late final TextEditingController _nameController;
  bool _isEditing = false;
  bool _isSaving = false;
  File? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.nombre);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return;
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedImage != null) {
      setState(() {
        _pickedImageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _saveProfile(String lang) async {
    if (widget.user.id == null) return;

    setState(() => _isSaving = true);

    try {
      String? newPhotoUrl = widget.user.photoUrl;

      if (_pickedImageFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/${widget.user.id}.jpg');
        final uploadTask = storageRef.putFile(_pickedImageFile!);
        final snapshot = await uploadTask.whenComplete(() {});
        newPhotoUrl = await snapshot.ref.getDownloadURL();
      }

      final newName = _nameController.text.trim();
      final updateData = {
        'nombre': newName,
        'photoUrl': newPhotoUrl,
      };

      await FirebaseFirestore.instance.collection('users').doc(widget.user.id).update(updateData);
      
      final updatedUser = widget.user.copyWith(nombre: newName, photoUrl: newPhotoUrl);
      widget.onProfileUpdated(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.get('profile_updated', lang)), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppTranslations.get('profile_update_error', lang)}: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
          _pickedImageFile = null;
        });
      }
    }
  }
  
  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(kSessionUserIdKey);
      await prefs.remove(kSessionTokenKey);
    } catch (e) {
      appLog('Failed clearing local session prefs: $e', tag: 'session');
    }

    try {
      final doc = FirebaseFirestore.instance.collection('users').doc(widget.user.id);
      await doc.update({
        'sessionToken': FieldValue.delete(),
        'sessionTokenExpiry': FieldValue.delete(),
      });
    } catch (e) {
      appLog('Failed clearing sessionToken on Firestore: $e', tag: 'session');
    }

    try {
      await fb_auth.FirebaseAuth.instance.signOut();
    } catch (_) {}

    if (!mounted) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final localization = context.watch<LocalizationService>();
    final lang = localization.currentLanguageCode;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildHeader(context, textTheme),
          _buildProfileForm(textTheme, lang, colorScheme),
          const Divider(),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.themeModeNotifier,
            builder: (context, currentMode, child) {
              return SwitchListTile(
                title: Text(AppTranslations.get('dark_mode', lang)),
                value: currentMode == ThemeMode.dark,
                onChanged: (isDark) {
                  ThemeService.toggleTheme();
                },
                secondary: Icon(
                  currentMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                  color: colorScheme.onSurface,
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.language, color: colorScheme.onSurface),
            title: Text(AppTranslations.get('change_language', lang)),
            onTap: () async => await localization.toggleLanguage(),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: colorScheme.onSurface),
            title: Text(AppTranslations.get('logout', lang)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    final colorScheme = Theme.of(context).colorScheme;
    ImageProvider? backgroundImage;
    if (_pickedImageFile != null) {
      backgroundImage = FileImage(_pickedImageFile!);
    } else if (widget.user.photoUrl != null && widget.user.photoUrl!.isNotEmpty) {
      backgroundImage = NetworkImage(widget.user.photoUrl!);
    }

    return UserAccountsDrawerHeader(
      accountName: Text(_nameController.text, style: textTheme.titleLarge?.copyWith(color: Colors.white)),
      accountEmail: Text(widget.user.correo, style: textTheme.bodyMedium?.copyWith(color: Colors.white70)),
      currentAccountPicture: InkWell(
        onTap: _isEditing ? _pickImage : null,
        child: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: backgroundImage,
              child: backgroundImage == null
                  ? Text(
                      widget.user.nombre.isNotEmpty ? widget.user.nombre[0].toUpperCase() : '?',
                      style: textTheme.headlineMedium?.copyWith(color: colorScheme.primary),
                    )
                  : null,
            ),
            if (_isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: colorScheme.primary,
                  child: const Icon(Icons.edit, size: 14, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
      decoration: BoxDecoration(color: colorScheme.primary),
    );
  }

  Widget _buildProfileForm(TextTheme textTheme, String lang, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(AppTranslations.get('edit_profile', lang), style: textTheme.titleLarge),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: AppTranslations.get('name', lang)),
            enabled: _isEditing,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: widget.user.correo,
            decoration: InputDecoration(labelText: AppTranslations.get('email_non_editable', lang)),
            enabled: false,
          ),
          const SizedBox(height: 24),
          Center(
            child: _isSaving
              ? const CircularProgressIndicator()
              : (_isEditing ? _buildSaveCancelButtons(lang) : _buildEditButton(lang, colorScheme)),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(String lang, ColorScheme colorScheme) {
    return ElevatedButton.icon(
      icon: Icon(Icons.edit, color: colorScheme.onSurface),
      label: Text(AppTranslations.get('edit', lang), style: TextStyle(color: colorScheme.onSurface)),
      onPressed: () => setState(() => _isEditing = true),
    );
  }

  Widget _buildSaveCancelButtons(String lang) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        TextButton(
          child: Text(AppTranslations.get('cancel', lang), style: TextStyle(color: colorScheme.onSurface)),
          onPressed: () {
            setState(() {
              _isEditing = false;
              _pickedImageFile = null;
              _nameController.text = widget.user.nombre;
            });
          },
        ),
        ElevatedButton(
          onPressed: () => _saveProfile(lang),
          child: Text(AppTranslations.get('save', lang), style: TextStyle(color: colorScheme.onSurface)),
        ),
      ],
    );
  }
}
