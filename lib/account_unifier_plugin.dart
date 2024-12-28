import 'package:flutter/services.dart';

class AccountUnifierPlugin {
  static const MethodChannel _channel = MethodChannel('account_unifier_plugin');

  /// Fetch all accounts
  /// Fetch the account
  static Future<Map<String, String>?> getAccount() async {
    try {
      final account =
          await _channel.invokeMethod<Map<dynamic, dynamic>>('getAccount');
      if (account == null) {
        return null;
      }
      return account.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (e) {
      print('Error fetching account: $e');
      return null;
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
      final bool result = await _channel.invokeMethod('isPackageInstalled');
      return result;
    } catch (e) {
      print('Error checking installation of unifier: $e');
      return false;
    }
  }

  /// Fetch the JSON text stored in the account
  static Future<String?> getJsonText() async {
    try {
      final String jsonText = await _channel.invokeMethod('getJsonText');
      return jsonText;
    } catch (e) {
      print('Error fetching JSON text: $e');
      return null;
    }
  }

  /// Insert or replace JSON text in the account
  static Future<bool> insertJsonText(String jsonText) async {
    try {
      final bool result =
          await _channel.invokeMethod('insertJsonText', {'jsonText': jsonText});
      return result;
    } catch (e) {
      print('Error inserting JSON text: $e');
      return false;
    }
  }
}
