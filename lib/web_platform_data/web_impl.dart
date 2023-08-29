import 'package:alchemy/web_platform_data/interface.dart';
import 'package:js/js.dart';

class WebPlatformDataImpl extends WebPlatformData {
  @override
  UserAgent get userAgent {
    final data = _identifyUserAgent();
    return UserAgent(isMobile: data.isMobile, platform: data.platform, browser: data.browser, engine: data.engine);
  }
}

WebPlatformData getInstance() => WebPlatformDataImpl();

@JS()
class _JsUserAgent {
  external bool isMobile;
  external String platform;
  external String browser;
  external String engine;
}

@JS('window.identifyUserAgent')
external _JsUserAgent _identifyUserAgent();
