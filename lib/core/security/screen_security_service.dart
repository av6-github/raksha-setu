// lib/core/security/screen_security_service.dart
// Controls screenshot and screen-recording prevention (FLAG_SECURE) for sensitive clinical views

class ScreenSecurityService {
  bool _isScreenshotBlocked = true;

  bool get isScreenshotBlocked => _isScreenshotBlocked;

  /// Toggles screenshot block policy (active by default for officer clinical data privacy)
  void setScreenshotProtection(bool enable) {
    _isScreenshotBlocked = enable;
  }
}
