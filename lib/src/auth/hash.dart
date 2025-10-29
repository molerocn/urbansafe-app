import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Helper para producir un SHA-256 en hexadecimal de password+salt (se utiliza el email como salt)
String hashPassword(String password, String salt) {
  final bytes = utf8.encode(password + salt);
  return sha256.convert(bytes).toString();
}
