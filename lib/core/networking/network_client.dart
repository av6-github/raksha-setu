// lib/core/networking/network_client.dart
// Network connectivity monitoring and HTTP communication layer

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../logging/app_logger.dart';

abstract class INetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _hasActiveConnection(results);
    } catch (e) {
      AppLogger.warning('Failed to check connectivity', error: e);
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_hasActiveConnection);
  }

  bool _hasActiveConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }
}
