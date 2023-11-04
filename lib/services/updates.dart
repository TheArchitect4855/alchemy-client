import 'dart:io';

import 'package:alchemy/logger.dart';
import 'package:alchemy/semver.dart';
import 'package:alchemy/services/requests.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdatesService {
  static final instance = UpdatesService();

  _AppVersion? _version;

  Future<String?> getDownloadLink(RequestsService requests) async {
    final versionInfo = await _getAppVersion(requests);
    return versionInfo.downloads.downloadLink;
  }

  Future<bool> isUpdateRequired(RequestsService requests) async {
    try {
      final versionInfo = await _getAppVersion(requests);
      final packageInfo = await PackageInfo.fromPlatform();
      final packageVersion = SemVer.parse(packageInfo.version);
      return versionInfo.version > packageVersion && versionInfo.isUpdateRequired && versionInfo.releaseDate.isBefore(DateTime.now());
    } on FormatException catch (e) {
      Logger.exception(runtimeType, e);
      return true;
    }
  }

  Future<_AppVersion> _getAppVersion(RequestsService requests) async {
    Logger.info(runtimeType, 'Getting app version...');
    _version ??= await requests.get('/versions/client', _AppVersion.fromJson);
    Logger.info(runtimeType, 'Got version info: $_version');
    return _version!;
  }
}

class _AppVersion {
  final SemVer version;
  final bool isUpdateRequired;
  final DateTime releaseDate;
  final _AppVersionDownloads downloads;

  _AppVersion.fromJson(Map<String, dynamic> data)
    : version = SemVer.parse(data['version']),
    isUpdateRequired = data['isUpdateRequired'],
    releaseDate = DateTime.parse(data['releaseDate']),
    downloads = _AppVersionDownloads.fromJson(data['downloads']);

  @override
  String toString() => 'Version $version, released $releaseDate.\n\tUpdate required: $isUpdateRequired\n\t$downloads';
}

class _AppVersionDownloads {
  final String android;
  final String ios;

  _AppVersionDownloads.fromJson(Map<String, dynamic> data) : android = data['android'], ios = data['ios'];

  String? get downloadLink {
    if (Platform.isAndroid) {
      return android;
    } else if (Platform.isIOS) {
      return ios;
    } else {
      return null;
    }
  }

  @override
  String toString() => 'Downloads available at\n\t"$android" for Android and\n\t"$ios" for iOS';
}
