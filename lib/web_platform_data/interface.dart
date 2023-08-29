import './stub_impl.dart' if (dart.library.html) './web_impl.dart';

abstract class WebPlatformData {
  UserAgent get userAgent;

  static WebPlatformData? _instance;

  static WebPlatformData get instance {
    _instance ??= getInstance();
    return _instance!;
  }
}

class UserAgent {
  bool isMobile;
  String platform;
  String browser;
  String engine;

  UserAgent({ required this.isMobile, required this.platform, required this.browser, required this.engine });
}
