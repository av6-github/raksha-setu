// test/widget/phase17_widget_test.dart
// Widget tests for Phase 17: OfflineSyncScreen (Sync Status, On-Device Baseline, SMS Fallback, and Screen Hardening)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raksha_welfare/core/networking/network_client.dart';
import 'package:raksha_welfare/core/security/screen_security_service.dart';
import 'package:raksha_welfare/core/security/secure_storage_service.dart';
import 'package:raksha_welfare/core/storage/encrypted_local_storage_service.dart';
import 'package:raksha_welfare/core/storage/offline_queue_service.dart';
import 'package:raksha_welfare/core/storage/sync_engine.dart';
import 'package:raksha_welfare/features/security/data/app_lock_service.dart';
import 'package:raksha_welfare/features/security/presentation/offline_sync_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeNetworkInfo implements INetworkInfo {
  bool isConnectedValue;
  FakeNetworkInfo({this.isConnectedValue = true});

  @override
  Future<bool> get isConnected async => isConnectedValue;

  @override
  Stream<bool> get onConnectivityChanged => Stream.value(isConnectedValue);
}

class FakeSecureStorageService implements ISecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<void> write(String key, String value) async => _data[key] = value;

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> delete(String key) async => _data.remove(key);

  @override
  Future<void> deleteAll() async => _data.clear();

  @override
  Future<bool> containsKey(String key) async => _data.containsKey(key);
}

void main() {
  group('Phase 17: OfflineSyncScreen Widget Tests', () {
    late SharedPreferences prefs;
    late OfflineQueueService queueService;
    late FakeNetworkInfo fakeNetwork;
    late SyncEngine syncEngine;
    late EncryptedLocalStorageService encryptedStorage;
    late FakeSecureStorageService fakeSecureStorage;
    late AppLockService appLockService;
    late ScreenSecurityService screenSecurityService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      queueService = OfflineQueueService(prefs: prefs);
      fakeNetwork = FakeNetworkInfo(isConnectedValue: true);
      syncEngine = SyncEngine(
        queueService: queueService,
        networkInfo: fakeNetwork,
      );
      encryptedStorage = EncryptedLocalStorageService(prefs: prefs);
      fakeSecureStorage = FakeSecureStorageService();
      appLockService = AppLockService(secureStorage: fakeSecureStorage);
      screenSecurityService = ScreenSecurityService();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: OfflineSyncScreen(
          syncEngine: syncEngine,
          queueService: queueService,
          networkInfo: fakeNetwork,
          encryptedStorage: encryptedStorage,
          appLockService: appLockService,
          screenSecurityService: screenSecurityService,
        ),
      );
    }

    testWidgets('Renders all 4 hardening cards on screen', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Offline-First & Sync Hardening'), findsOneWidget);
      expect(find.text('Network Connected'), findsOneWidget);
      expect(find.text('On-Device Rolling Baseline Engine'), findsOneWidget);
      expect(find.text('Tactical Zero-Data Fallback (SMS / IVR)'), findsOneWidget);
      expect(find.text('Device Privacy & Screen Hardening'), findsOneWidget);
    });

    testWidgets('Toggling simulated airplane mode disables Sync Now button', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final airplaneSwitch = find.byType(Switch).first;
      await tester.tap(airplaneSwitch);
      await tester.pumpAndSettle();

      expect(find.text('Simulated Airplane Mode (Offline)'), findsOneWidget);

      final syncNowBtn = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Sync Now'));
      expect(syncNowBtn.onPressed, isNull); // Disabled when airplane mode simulated
    });

    testWidgets('Displays on-device baseline metrics and CUSUM status', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('5 entries'), findsOneWidget);
      expect(find.text('Avg Sleep'), findsOneWidget);
      expect(find.text('Avg Workload'), findsOneWidget);
    });

    testWidgets('Displays formatted SMS check-in payload and toll-free IVR helper', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('RAKSHA CHK TK-8492-4102-9912'), findsOneWidget);
      expect(find.textContaining('14416'), findsOneWidget);
    });

    testWidgets('Toggling screenshot protection updates switch state', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final screenshotTile = find.widgetWithText(SwitchListTile, 'Screenshot & Screen-Recording Block');
      expect(screenshotTile, findsOneWidget);

      await tester.tap(screenshotTile);
      await tester.pumpAndSettle();

      expect(screenSecurityService.isScreenshotBlocked, isFalse);
    });
  });
}
