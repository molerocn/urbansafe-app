import 'package:flutter/foundation.dart';

// Wrapper ligero de logger utilizado en toda la aplicación.
void appLog(String message, {String? tag}) {
  if (!kDebugMode) {
    return;
  }
  if (tag != null && tag.isNotEmpty) {
    debugPrint('[$tag] $message');
  } else {
    debugPrint(message);
  }
}
