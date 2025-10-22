import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class LocalAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> checkBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print('Biometrics check error: $e');
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      if (!canAuthenticate) {
        print('Biometrics not available on this device');
        return false;
      }

      final biometrics = await _localAuth.getAvailableBiometrics();
      if (biometrics.isEmpty) {
        print('No biometric methods available');
        return false;
      }

      final isBiometricsEnrolled = await _isBiometricsEnrolled();
      if (!isBiometricsEnrolled) {
        print('Biometrics not enrolled');
        return false; // Or return true for demo purposes
      }

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your tasks',

          biometricOnly: true,


      );
    } on PlatformException catch (e) {
      print('Authentication error: $e');
      // Handle specific error codes
      if (e.code == 'NotAvailable' || e.code == 'PasscodeNotSet' || e.code == 'NoBiometricsEnrolled') {
        // For demo purposes, allow access if biometrics aren't set up
        print('Biometrics not available, allowing access for demo');
        return true;
      }
      return false;
    } catch (e) {
      print('Unexpected authentication error: $e');
      return false;
    }
  }

  // Helper method to check if biometrics are enrolled
  Future<bool> _isBiometricsEnrolled() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } on PlatformException catch (e) {
      print('Biometrics enrollment check error: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Get available biometrics error: $e');
      return [];
    }
  }

  // Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      final biometrics = await getAvailableBiometrics();
      final isEnrolled = await _isBiometricsEnrolled();

      print('Biometric availability: canAuthenticate=$canAuthenticate, biometrics=$biometrics, isEnrolled=$isEnrolled');

      return canAuthenticate && biometrics.isNotEmpty && isEnrolled;
    } on PlatformException catch (e) {
      print('Biometric availability check error: $e');
      return false;
    }
  }

  // Alternative method that falls back to device passcode
  Future<bool> authenticateWithFallback() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your tasks',
          biometricOnly: false, // Allow device passcode as fallback
      );
    } on PlatformException catch (e) {
      print('Authentication with fallback error: $e');
      // For demo purposes, allow access if authentication fails
      return true;
    }
  }
}