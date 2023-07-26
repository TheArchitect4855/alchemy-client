import 'package:alchemy/logger.dart';
import 'package:alchemy/services/requests.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

const notificationPromptKey = 'NOTIFICATIONS_PROMPT';

class NotificationsService {
  static final NotificationsService instance = NotificationsService();

  bool get isEnabled => _isEnabled;
  bool get isInitialized => _isInitialized;

  final FirebaseMessaging _fbm = FirebaseMessaging.instance;
  bool _isEnabled = false;
  bool _isInitialized = false;

  Future<void> initialize(RequestsService requests) async {
    if (_isInitialized) throw StateError('already initialized');

    final prefs = await SharedPreferences.getInstance();
    final shownPrompt = prefs.getBool(notificationPromptKey) ?? false;

    final settings = await _fbm.getNotificationSettings();
    Logger.info(runtimeType, 'Auth status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined || !shownPrompt) {
      await requestPermissions();
      if (!shownPrompt) await prefs.setBool(notificationPromptKey, true);
    } else {
      _isEnabled = _isStatusEnabled(settings.authorizationStatus);
    }

    if (_isEnabled) {
      final token = await _fbm.getToken();
      if (token == null) {
        Logger.warn(runtimeType, 'FCM Token was null');
      } else {
        Logger.debug(runtimeType, 'FCM token: $token');
        await requests.put(
            '/messages/id',
            {
              'fcmToken': token,
            },
            (v) => v);
      }
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
