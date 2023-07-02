import 'dart:convert';
import 'dart:typed_data';

import 'package:alchemy/logger.dart';

class Jwt {
  static final jwtPattern = RegExp(r'^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+){2}$');

  final Map<String, dynamic> header;
  final Map<String, dynamic> payload;
  final Uint8List signature;

  Jwt(this.header, this.payload, this.signature);

  static Jwt? decode(String token) {
    if (!jwtPattern.hasMatch(token)) return null;

    final parts = token.split('.');
    try {
      final header = utf8.decode(_decodePart(parts[0]));
      final payload = utf8.decode(_decodePart(parts[1]));
      return Jwt(jsonDecode(header), jsonDecode(payload), _decodePart(parts[2]));
    } catch (e) {
      Logger.debug(Jwt, 'Failed to decode JWT: $e');
      return null;
    }
  }

  static Uint8List _decodePart(String part) {
    while (part.length % 4 != 0) {
      part += '=';
    }

    return base64Url.decode(part);
  }
}
