import 'package:alchemy/logger.dart';
import 'package:alchemy/services/auth.dart';
import 'package:alchemy/services/requests.dart';
import 'package:alchemy/web_platform_data/interface.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const notificationPromptKey = 'NOTIFICATIONS_PROMPT';
const _webVapidKey =
    'BJl_TKOFDQSeCR7qMgudU_pnhkz2eW6MygZ8GB9Jb-IjUfEiaQm4i-trxzrAt3FF_lWNKsZm3xfEIYlaMxsHqj4';

abstract class NotificationsService {
  bool get isEnabled;
  bool get isInitialized;

  Future<void> initialize();
  Future<String?> _getToken();

  Future<void> updateToken(RequestsService requests) async {
    if (!isEnabled) throw StateError('not enabled');
    final token = await _getToken();
    if (token == null) {
      Logger.warn(runtimeType, 'Token was null');
      return;
    }

    Logger.debug(runtimeType, 'Token: $token');
    await requests.put('/messages/id', {'token': token}, (v) => v);
  }

  static final NotificationsService instance = _createInstance();

  static NotificationsService _createInstance() {
    if (_isFcmSupported()) {
      return FcmNotificationsService();
    } else {
      return SmsNotificationsService();
    }
  }

  static bool _isFcmSupported() {
    if (!kIsWeb) return true;

    final ua = WebPlatformData.instance.userAgent;
    Logger.debug(NotificationsService,
        'Web Platform Data: ${ua.browser} ${ua.engine} ${ua.isMobile} ${ua.platform}');
    return ua.platform != 'ios';
  }
}

class FcmNotificationsService extends NotificationsService {
  @override
  bool get isEnabled => _isEnabled;

  @override
  bool get isInitialized => _isInitialized;

  final FirebaseMessaging _fbm = FirebaseMessaging.instance;
  final List<void Function(RemoteMessage)> _onMessageListeners = [];
  final List<void Function(RemoteMessage)> _onMessageOpenedAppListeners = [];
  final List<RemoteMessage> _openAppMessages = [];
  bool _isEnabled = false;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) throw StateError('already initialized');

    final prefs = await SharedPreferences.getInstance();
    final shownPrompt = prefs.getBool(notificationPromptKey) ?? false;

    final settings = await _fbm.getNotificationSettings();
    Logger.info(runtimeType, 'Auth status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined ||
        !shownPrompt) {
      await requestPermissions();
      if (!shownPrompt) await prefs.setBool(notificationPromptKey, true);
    } else {
      _isEnabled = _isStatusEnabled(settings.authorizationStatus);
    }

    if (_isEnabled) {
      await updateToken(RequestsService.instance);
      FirebaseMessaging.onMessage
          .listen((ev) => _onMessageListeners.forEach((el) => el(ev)));
      FirebaseMessaging.onMessageOpenedApp.listen((ev) {
        _openAppMessages.add(ev);
        _onMessageOpenedAppListeners.forEach((el) => el(ev));
      });
    }

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    Logger.info(runtimeType, 'Request permissions...');
    NotificationSettings settings;
    do {
      settings = await _fbm.requestPermission();
    } while (settings.authorizationStatus == AuthorizationStatus.notDetermined);
    Logger.info(runtimeType, 'Auth status: ${settings.authorizationStatus}');
    _isEnabled = _isStatusEnabled(settings.authorizationStatus);
  }

  void addOnMessageListener(void Function(RemoteMessage message) fn) =>
      _onMessageListeners.add(fn);
  void removeOnMessageListener(void Function(RemoteMessage message) fn) =>
      _onMessageListeners.remove(fn);
  void removeOnMessageOpenedAppListener(
          void Function(RemoteMessage message) fn) =>
      _onMessageOpenedAppListeners.remove(fn);

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

  @override
  Future<String?> _getToken() {
    return _fbm.getToken(vapidKey: _webVapidKey);
  }
}

class SmsNotificationsService extends NotificationsService {
  @override
  bool get isEnabled => true;

  @override
  bool get isInitialized => _isInitialized;

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) throw StateError('already initialized');
    await updateToken(RequestsService.instance);
    _isInitialized = true;
  }

  @override
  Future<String?> _getToken() async {
    final auth = AuthService.instance;
    return auth.contact?.phone;
  }
}
