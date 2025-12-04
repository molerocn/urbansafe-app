import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../src/auth/hash.dart';
import '../src/app_constants.dart';

const String _sendRecoveryEmailFunctionUrl =
    'https://us-central1-urbansafe-app01.cloudfunctions.net/sendPasswordRecoveryEmail';
const String _resetPasswordFunctionUrl =
    'https://us-central1-urbansafe-app01.cloudfunctions.net/resetPassword';

class PasswordRecoveryService {
  static const String _recoveryCodesCollection = 'password_recovery';
  static const int _codeExpirationMinutes = 15;
  static const String _sendRecoveryEmailFunctionUrl =
      'https://us-central1-urbansafe-app01.cloudfunctions.net/sendPasswordRecoveryEmail';

  /// Generate and store a password recovery code for a user, send via email
  /// Returns the generated code on success, or null if user not found or error.
  Future<String?> sendRecoveryCode(String email) async {
    try {
      // Find user by email
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('correo', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null; // User not found
      }

      final userDoc = query.docs.first;
      final userId = userDoc.id;

      // Generate a 6-digit code
      final code = (100000 + DateTime.now().millisecondsSinceEpoch % 900000)
          .toString();

      // Store code with expiration
      final expiresAt = DateTime.now().add(
        Duration(minutes: _codeExpirationMinutes),
      );

      await FirebaseFirestore.instance
          .collection(_recoveryCodesCollection)
          .doc(userId)
          .set({
            'code': code,
            'email': email,
            'expiresAt': Timestamp.fromDate(expiresAt),
            'createdAt': Timestamp.now(),
            'used': false,
          });

      // Build list of recipient emails from user document (supports multiple stored emails)
      final recipients = <String>{};
      try {
        final data = userDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          final primary = data['correo'] as String?;
          if (primary != null && primary.isNotEmpty)
            recipients.add(primary.trim());

          final secondary = data['correo2'] as String?;
          if (secondary != null && secondary.isNotEmpty)
            recipients.add(secondary.trim());

          final emailsList = data['emails'];
          if (emailsList is List) {
            for (final e in emailsList) {
              if (e is String && e.isNotEmpty) recipients.add(e.trim());
            }
          }
        }
      } catch (_) {
        // ignore and fall back to input email
      }

      // Always include the email provided by the user (in case schema differs)
      recipients.add(email.trim());

      // Send email to all recipients via Cloud Function (best-effort)
      for (final to in recipients) {
        try {
          final response = await http
              .post(
                Uri.parse(_sendRecoveryEmailFunctionUrl),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'email': to, 'code': code}),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode != 200) {
            // log or ignore
          }
        } catch (e) {
          // email send error for this recipient - ignore and continue
        }
      }

      // Return the generated code so the app can display it if needed
      return code;
    } catch (e) {
      // Silent error handling
      return null;
    }
  }

  /// Verify the recovery code and reset password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      // Find user by email
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('correo', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        return {'success': false, 'message': 'User not found'};
      }

      final userId = userQuery.docs.first.id;

      // Get recovery code document
      final recoveryDoc = await FirebaseFirestore.instance
          .collection(_recoveryCodesCollection)
          .doc(userId)
          .get();

      if (!recoveryDoc.exists) {
        return {'success': false, 'message': 'No recovery code found'};
      }

      final recoveryData = recoveryDoc.data() as Map<String, dynamic>;
      final storedCode = recoveryData['code'] as String?;
      final expiresAt = recoveryData['expiresAt'] as Timestamp?;
      final used = recoveryData['used'] as bool? ?? false;

      // Validate code
      if (storedCode != code) {
        return {'success': false, 'message': 'Invalid recovery code'};
      }

      // Check expiration
      if (expiresAt == null || expiresAt.toDate().isBefore(DateTime.now())) {
        return {'success': false, 'message': 'Recovery code has expired'};
      }

      // Check if code was already used
      if (used) {
        return {
          'success': false,
          'message': 'Recovery code has already been used',
        };
      }

      // Hash new password
      final newPasswordHash = hashPassword(newPassword, email);

      // Update user password
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'passwordHash': newPasswordHash,
      });

      // Mark code as used
      await FirebaseFirestore.instance
          .collection(_recoveryCodesCollection)
          .doc(userId)
          .update({'used': true});

      return {'success': true, 'message': 'Password reset successfully'};
    } catch (e) {
      // Silent error handling
      return {'success': false, 'message': 'Error resetting password'};
    }
  }

  /// Get recovery code for testing (dev only)
  Future<String?> getRecoveryCodeForTesting(String email) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('correo', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      final userId = query.docs.first.id;
      final doc = await FirebaseFirestore.instance
          .collection(_recoveryCodesCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data()?['code'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
