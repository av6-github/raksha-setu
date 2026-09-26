import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/core/security/secure_storage_service.dart';
import 'package:raksha_welfare/features/security/data/app_lock_service.dart';
import 'package:raksha_welfare/features/security/presentation/app_lock_view_model.dart';

class MockSecureStorageService implements ISecureStorageService {
  final Map<String, String> _store = {};

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async => _store[key] = value;

  @override
  Future<void> delete(String key) async => _store.remove(key);

  @override
  Future<void> deleteAll() async => _store.clear();

  @override
  Future<bool> containsKey(String key) async => _store.containsKey(key);
}

void main() {
  group('Phase 2 — App Lock & Security Unit Tests', () {
    late MockSecureStorageService secureStorage;
    late AppLockService appLockService;
    late AppLockViewModel viewModel;

    setUp(() {
      secureStorage = MockSecureStorageService();
      appLockService = AppLockService(secureStorage: secureStorage);
      viewModel = AppLockViewModel(appLockService: appLockService);
    });

    test('App lock is disabled initially', () async {
      await viewModel.loadSettings();

      expect(viewModel.isLockEnabled, isFalse);
      expect(viewModel.isUnlocked, isTrue); // Not locked when disabled
    });

    test('Setting up PIN enables app lock and validates PIN', () async {
      await viewModel.loadSettings();

      // Setting PIN shorter than 4 digits fails
      final fail = await viewModel.setupPin('12');
      expect(fail, isFalse);
      expect(viewModel.errorMessage, contains('at least 4 digits'));

      // Setup 4-digit PIN
      final success = await viewModel.setupPin('4892');
      expect(success, isTrue);
      expect(viewModel.isLockEnabled, isTrue);

      // Verify correct PIN
      final unlockSuccess = await viewModel.unlockWithPin('4892');
      expect(unlockSuccess, isTrue);

      // Verify incorrect PIN
      final unlockFail = await viewModel.unlockWithPin('0000');
      expect(unlockFail, isFalse);
    });

    test('Locking and unlocking state machine', () async {
      await viewModel.setupPin('1234');

      // Trigger lock
      viewModel.lock();
      expect(viewModel.isUnlocked, isFalse);

      // Incorrect PIN leaves locked
      await viewModel.unlockWithPin('9999');
      expect(viewModel.isUnlocked, isFalse);

      // Correct PIN unlocks
      await viewModel.unlockWithPin('1234');
      expect(viewModel.isUnlocked, isTrue);
    });

    test('Disabling app lock clears persistence', () async {
      await viewModel.setupPin('7788');
      expect(viewModel.isLockEnabled, isTrue);

      await viewModel.disableLock();
      expect(viewModel.isLockEnabled, isFalse);
      expect(viewModel.isUnlocked, isTrue);

      // PIN no longer verifies
      final verified = await appLockService.verifyPin('7788');
      expect(verified, isFalse);
    });
  });
}
