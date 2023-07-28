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
  final List<void Function(RemoteMessage)> _onMessageListeners = [];
  final List<void Function(RemoteMessage)> _onMessageOpenedAppListeners = [];
  final List<RemoteMessage> _openAppMessages = [];
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
      await updateToken(requests);
      FirebaseMessaging.onMessage.listen((ev) => _onMessageListeners.forEach((el) => el(ev)));
      FirebaseMessaging.onMessageOpenedApp.listen((ev) {
        _openAppMessages.add(ev);
        _onMessageOpenedAppListeners.forEach((el) => el(ev));
      });
    }

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    Logger.info(runtimeType, 'Request permissions...');
    final settings = await _fbm.requestPermission();
    Logger.info(runtimeType, 'Auth status: ${settings.authorizationStatus}');
    _isEnabled = _isStatusEnabled(settings.authorizationStatus);
  }

  Future<void> updateToken(RequestsService requests) async {
    if (!_isEnabled) throw StateError('not enabled');
    final token = await _fbm.getToken();
    if (token == null) {
      Logger.warn(runtimeType, 'FCM Token was null');
      return;
    }

    Logger.debug(runtimeType, 'FCM token: $token');
    await requests.put(
        '/messages/id',
        {
          'fcmToken': token,
        },
        (v) => v);
  }

  void addOnMessageListener(void Function(RemoteMessage message) fn) => _onMessageListeners.add(fn);
  void removeOnMessageListener(void Function(RemoteMessage message) fn) => _onMessageListeners.remove(fn);
  void removeOnMessageOpenedAppListener(void Function(RemoteMessage message) fn) => _onMessageOpenedAppListeners.remove(fn);

  void addOnMessageOpenedAppListener(void Function(RemoteMessage message) fn) {
    _openAppMessages.forEach(fn);
    _onMessageOpenedAppListeners.add(fn);
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
