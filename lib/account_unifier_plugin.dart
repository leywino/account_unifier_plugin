import 'package:flutter/services.dart';

class AccountUnifierPlugin {
  static const MethodChannel _channel = MethodChannel('account_unifier_plugin');

  /// Fetch all accounts
  static Future<List<Map<String, String>>> getAccounts() async {
    try {
      final List<dynamic> accounts = await _channel.invokeMethod('getAccounts');
      return accounts.map((account) {
        return Map<String, String>.from(account as Map);
      }).toList();
    } catch (e) {
      print('Error fetching accounts: $e');
      return [];
    }
  }

  /// Add a new account
  static Future<bool> addAccount(
      String username, String authToken, String refreshToken) async {
    try {
      final bool result = await _channel.invokeMethod('addAccount', {
        'username': username,
        'authToken': authToken,
        'refreshToken': refreshToken,
      });
      return result;
    } catch (e) {
      print('Error adding account: $e');
      return false;
    }
  }

  /// Fetch the email of the stored account
  static Future<String?> getEmail() async {
    try {
      final String email = await _channel.invokeMethod('getEmail');
      return email;
    } catch (e) {
      print('Error fetching email: $e');
      return null;
    }
  }

  /// Update the access token for the stored account
  static Future<bool> updateAccessToken(String authToken) async {
    try {
      final bool result = await _channel
          .invokeMethod('updateAccessToken', {'authToken': authToken});
      return result;
    } catch (e) {
      print('Error updating access token: $e');
      return false;
    }
  }

  /// Check if account unifier is installed on the device
  static Future<bool> isPackageInstalled() async {
    try {
      final bool result = await _channel
          .invokeMethod('isPackageInstalled');
      return result;
    } catch (e) {
      print('Error checking installation of unifier: $e');
      return false;
    }
  }
}
