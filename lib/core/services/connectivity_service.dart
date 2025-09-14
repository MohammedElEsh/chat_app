import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;

class ConnectivityService {
  static ConnectivityService? _instance;
  static ConnectivityService get instance => _instance ??= ConnectivityService._internal();
  ConnectivityService._internal();

  bool _isConnected = true;
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  Timer? _connectivityTimer;

  Stream<bool> get connectivityStream => _connectivityController.stream;
  bool get isConnected => _isConnected;

  /// Initialize connectivity monitoring
  void initialize() {
    _startConnectivityCheck();
  }

  /// Start periodic connectivity checks
  void _startConnectivityCheck() {
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkConnectivity();
    });
    
    // Initial check
    checkConnectivity();
  }

  /// Check network connectivity
  Future<void> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 3),
      );
      
      final wasConnected = _isConnected;
      _isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      if (wasConnected != _isConnected) {
        _connectivityController.add(_isConnected);
        developer.log('Connectivity changed: $_isConnected');
      }
    } catch (e) {
      final wasConnected = _isConnected;
      _isConnected = false;
      
      if (wasConnected != _isConnected) {
        _connectivityController.add(_isConnected);
        developer.log('Connectivity lost: $e');
      }
    }
  }

  /// Check if network is available for calls
  Future<bool> isNetworkAvailableForCalls() async {
    await checkConnectivity();
    return _isConnected;
  }

  /// Dispose resources
  void dispose() {
    _connectivityTimer?.cancel();
    _connectivityController.close();
  }
}