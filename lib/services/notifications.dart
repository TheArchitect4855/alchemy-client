import 'package:alchemy/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsService {
  static final NotificationsService instance = NotificationsService();

  bool get isEnabled => _isEnabled;
  bool get isInitialized => _isInitialized;

  final FirebaseMessaging _fbm = FirebaseMessaging.instance;
  bool _isEnabled = false;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) throw StateError('already initialized');

    final settings = await _fbm.getNotificationSettings();
    Logger.info(runtimeType, 'Auth status: ${settings.authorizationStatus}');

    // TODO: Default seems to be "blocked" on Android, so check if this is
    // first startup and request permission.
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      await requestPermissions();
    } else {
      _isEnabled = _isStatusEnabled(settings.authorizationStatus);
    }

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    Logger.info(runtimeType, 'Request permissions...');
    final settings = await _fbm.requestPermission();
    Logger.info(runtimeType, 'Auth status: ${settings.authorizationStatus}');
    _isEnabled = _isStatusEnabled(settings.authorizationStatus);
  }

  static bool _isStatusEnabled(AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return true;
      case AuthorizationStatus.denied:
        return false;
      default:
        throw UnimplementedError('unhandled status $status');
    }
  }
}
