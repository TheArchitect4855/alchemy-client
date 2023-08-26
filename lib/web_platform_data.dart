import 'package:js/js.dart';

class WebPlatformData {
  static UserAgent get userAgent => _identifyUserAgent();
}

@JS()
class UserAgent {
  external bool isMobile;
  external String platform;
  external String browser;
  external String engine;
}

@JS('window.identifyUserAgent')
external UserAgent _identifyUserAgent();
