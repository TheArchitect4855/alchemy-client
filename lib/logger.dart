// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math';
import 'package:alchemy/encoding.dart';
import 'package:alchemy/hmac.dart';
import 'package:alchemy/services/requests.dart';
import 'package:alchemy/string_ring_buffer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum LogLevel {
  debug(0),
  info(1),
  warn(2),
  error(3);

  final int priority;

  const LogLevel(this.priority);
}

class Logger {
  static LogLevel level = LogLevel.warn;
  static final StringRingBuffer _buffer = StringRingBuffer(8192);

  static void debug(Type context, String message) => _log(LogLevel.debug, context, message);
  static void info(Type context, String message) => _log(LogLevel.info, context, message);
  static void warn(Type context, String message) => _log(LogLevel.warn, context, message);
  static void warnException(Type context, Exception exception) => _log(LogLevel.warn, context, exception.toString());
  static void error(Type context, String message) => _log(LogLevel.error, context, message);

  static void exception(Type context, Exception exception) {
    _log(LogLevel.error, context, exception.toString());

    final bytes = _buffer.asBytes();
    _buffer.clear();
    _getLogSignature()
      .then((v) => RequestsService.instance.postBinary('/logs', bytes, 'application/octet-stream', (v) => v, urlParams: v))
      .catchError((e) {
        print('Error uploading logs: $e');
        return null;
      });
  }

  static Future<Map<String, String>> _getLogSignature() async {
    const storage = FlutterSecureStorage();
    const key = 'logs-uid';
    var uid = await storage.read(key: key);
    if (uid == null) {
      final rng = Random.secure();
      final nums = <int>[];
      for (var i = 0; i < 15; i += 1) {
        nums.add(rng.nextInt(256));
      }

      uid = base32Encode(Uint8List.fromList(nums));
      await storage.write(key: key, value: uid);
    }

    final ts = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    final signature = sign(
        utf8.encode('$uid.$ts'),
        hexDecode(
            '362C56923B2E75F74E729D175C526873ABF61211C26F3F3C9BC8FD99EB8D26762482A789CCC2086E3C961DC0D4A509C3D6311F25EAB98A9C2F526664F0BFA7BD'));

    return {
      'id': uid,
      'signature': base64Url.encode(signature).replaceAll('=', ''),
      'timestamp': ts.toString(),
    };
  }

  static void _log(LogLevel level, Type context, String message) async {
    if (level.priority < Logger.level.priority && !kDebugMode) return;
    final now = DateTime.now();
    final timestamp = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final tag = level.name.toUpperCase();

    if (kDebugMode) print('[$tag $timestamp] $context: $message');

    try {
      final logJson = jsonEncode({
        'tag': tag,
        'context': context.toString(),
        'message': message,
        'timestamp': now.toIso8601String(),
      });

      if (kDebugMode && level.priority >= Logger.level.priority && logJson.length + 1 >= _buffer.capacity) {
        print('LOG IS TOO BIG FOR BUFFER: $logJson');
      } else if (logJson.length + 1 < _buffer.capacity) {
        _buffer.add('$logJson\n');
      }
    } on Exception catch (e) {
      if (kDebugMode) print('!!!FAILED WRITING TO LOG FILE!!!\n$e');
    }
  }
}
