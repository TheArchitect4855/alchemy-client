import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:alchemy/services/requests.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'encoding.dart';
import 'hmac.dart';

enum LogLevel {
  debug(0),
  info(1),
  warn(2),
  error(3);

  final int priority;

  const LogLevel(this.priority);
}

class Logger {
  static LogLevel level = kDebugMode ? LogLevel.debug : LogLevel.warn;
  static final _logFile = kIsWeb
      ? null
      : getApplicationDocumentsDirectory().then((v) =>
      File('${v.path}/${DateTime.now().toIso8601String()}.log')
          .openWrite(mode: FileMode.append));

  static void debug(Type context, String message) => _log(LogLevel.debug, context, message);
  static void info(Type context, String message) => _log(LogLevel.info, context, message);
  static void warn(Type context, String message) => _log(LogLevel.warn, context, message);
  static void warnException(Type context, Exception exception) => _log(LogLevel.warn, context, exception.toString());
  static void error(Type context, String message) => _log(LogLevel.error, context, message);
  static void exception(Type context, Exception exception) => _log(LogLevel.error, context, exception.toString());

  static Future<void> uploadPastLogs(RequestsService requests) async {
    final dir = await getApplicationDocumentsDirectory();
    final entries = await dir.list().toList();
    final stats = entries.map((e) => e.statSync()).toList();
    final logFileIndices = <int>[];
    for (var i = 0; i < entries.length; i += 1) {
      if (stats[i].type != FileSystemEntityType.file ||
          !entries[i].path.endsWith('.log')) continue;

      logFileIndices.add(i);
    }

    logFileIndices.sort((a, b) {
      final aMtime = stats[a].modified;
      final bMtime = stats[b].modified;
      return -(aMtime.compareTo(bMtime));
    });

    const maxUpload = 1e6;
    var totalUpload = 0;
    var i = 0;
    final upload = <int>[];
    while (totalUpload < maxUpload && i < logFileIndices.length) {
      final s = stats[logFileIndices[i]];
      if (totalUpload + s.size >= maxUpload) break;
      totalUpload += s.size;

      final stream = File(entries[logFileIndices[i]].path).openRead();
      final data = await stream.fold(<int>[], (p, e) {
        p.addAll(e);
        return p;
      });

      upload.addAll(data);
      i += 1;
    }

    final sig = await getLogSignature();
    await requests.postBinary('/logs', Uint8List.fromList(upload),
        'application/octet-stream', (v) => v,
        urlParams: sig);
  }

  static Future<Map<String, String>> getLogSignature() async {
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
    if (level.priority < Logger.level.priority) return;
    final now = DateTime.now();
    final timestamp = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final tag = level.name.toUpperCase();

    if (kDebugMode || _logFile == null) print('[$tag $timestamp] $context: $message');
    if (_logFile == null) return;

    try {
      final sink = await _logFile;
      final logJson = jsonEncode({
        'tag': tag,
        'context': context.toString(),
        'message': message,
        'timestamp': now.toIso8601String(),
      });

      sink!.writeln(logJson);
    } on Exception catch (e) {
      if (kDebugMode) print('!!!FAILED WRITING TO LOG FILE!!!\n$e');
    }
  }
}
