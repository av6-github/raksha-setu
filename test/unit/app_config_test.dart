import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/core/config/app_config.dart';

void main() {
  group('AppConfig Tests', () {
    test('prototype config initializes with expected defaults', () {
      final config = AppConfig.prototype();
      expect(config.environment, AppEnvironment.dev);
      expect(config.isDevelopment, isTrue);
      expect(config.isProduction, isFalse);
      expect(config.supabaseUrl, isNotEmpty);
      expect(config.supabaseAnonKey, isNotEmpty);
      expect(config.groqModel, 'qwen/qwen3.8-27b');
      expect(config.enableOfflineQueue, isTrue);
    });

    test('AppConfig.initialize sets static current property', () {
      final config = AppConfig.prototype();
      AppConfig.initialize(config);
      expect(AppConfig.current, equals(config));
    });
  });
}
