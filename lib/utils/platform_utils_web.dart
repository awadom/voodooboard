// lib/utils/platform_utils_web.dart
import 'package:web/web.dart' as web;

/// Returns true if the browser is a mobile browser based on the user agent
bool isMobileBrowser() {
  final userAgent = web.window.navigator.userAgent.toLowerCase();
  return userAgent.contains("iphone") ||
      userAgent.contains("ipad") ||
      userAgent.contains("android");
}
