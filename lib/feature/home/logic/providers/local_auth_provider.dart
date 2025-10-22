import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../../../../core/services/local_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final LocalAuthService _authService;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _biometricAvailable = false;
  String? _errorMessage;

  AuthProvider(this._authService) {
    _checkBiometricAvailability();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get biometricAvailable => _biometricAvailable;
  String? get errorMessage => _errorMessage;

  Future<void> _checkBiometricAvailability() async {
    _biometricAvailable = await _authService.isBiometricAvailable();
    notifyListeners();
  }

  Future<void> authenticate() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_biometricAvailable) {
        _isAuthenticated = await _authService.authenticate();

        if (!_isAuthenticated) {
          // If biometric fails, try with passcode fallback
          _isAuthenticated = await _authService.authenticateWithFallback();
        }
      } else {
        // For devices without biometrics or in simulator, use simple authentication
        _isAuthenticated = await _showSimpleAuthDialog(context as BuildContext);
      }
    } catch (e) {
      _errorMessage = 'Authentication failed: $e';
      print('Authentication error: $e');
      // For demo purposes, allow access even if authentication fails
      _isAuthenticated = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Simple authentication fallback (PIN or just a button)
  Future<bool> _showSimpleAuthDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('App Lock'),
        content: const Text('This app is secured. Tap Continue to access your tasks.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    ) ?? false;
  }

  void logout() {
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  void skipAuthentication() {
    _isAuthenticated = true;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Method to enable/disable authentication for development
  void enableForDevelopment() {
    _isAuthenticated = true;
    notifyListeners();
  }
}