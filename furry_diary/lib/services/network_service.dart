import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NetworkStatus {
  online,
  offline,
  weak,
}

class NetworkService {
  NetworkService(this._connectivity);

  final Connectivity _connectivity;
  final _statusController = StreamController<NetworkStatus>.broadcast();
  NetworkStatus _currentStatus = NetworkStatus.online;

  Stream<NetworkStatus> get statusStream => _statusController.stream;
  NetworkStatus get currentStatus => _currentStatus;
  bool get isOnline => _currentStatus != NetworkStatus.offline;

  Future<void> init() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    NetworkStatus newStatus;

    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      newStatus = NetworkStatus.offline;
    } else if (results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi)) {
      newStatus = NetworkStatus.online;
    } else {
      newStatus = NetworkStatus.online;
    }

    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _statusController.add(_currentStatus);
    }
  }

  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  void dispose() {
    _statusController.close();
  }
}

final networkServiceProvider = Provider<NetworkService>((ref) {
  final service = NetworkService(Connectivity());
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});

final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final service = ref.watch(networkServiceProvider);
  return service.statusStream;
});
