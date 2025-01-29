import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class AccountUnifierPlugin {
  static const MethodChannel _channel = MethodChannel('account_unifier_plugin');

  /// Fetch all accounts
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

  /// Update the kBaseUrl in the account unifier
  static Future<bool> updateBaseUrl(String kBaseUrl) async {
    try {
      final bool result =
          await _channel.invokeMethod('updateBaseUrl', {'kBaseUrl': kBaseUrl});
      return result;
    } catch (e) {
      print('Error updating kBaseUrl: $e');
      return false;
    }
  }

  /// Method to delete account on logout
  static Future<bool> deleteAccount() async {
    try {
      final bool result = await _channel.invokeMethod('deleteAccount');
      return result;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  /// Fetch the kBaseUrl from the account unifier
  static Future<String?> getBaseUrl() async {
    try {
      final String? baseUrl = await _channel.invokeMethod('getBaseUrl');
      return baseUrl;
    } catch (e) {
      print('Error fetching kBaseUrl: $e');
      return null;
    }
  }

  /// Refresh the access token using the refresh token
  static Future<String?> refreshToken([String? kBaseUrl]) async {
    const String defaultBaseUrl = "";
    final String baseUrl = kBaseUrl ?? defaultBaseUrl;

    try {
      // Fetch the stored refresh token
      final account = await getAccount();
      final refreshToken = account?['refreshToken'];
      if (refreshToken == null || refreshToken.isEmpty) {
        print('Error: No refresh token found');
        return null;
      }

      // Make API call to get a new access token
      final dio = Dio();
      final response = await dio.post(
        '$baseUrl/api/regenerate-token',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final newAuthToken = responseData['access'];

        if (newAuthToken == null || newAuthToken.isEmpty) {
          print('Error: Invalid response from server');
          return null;
        }

        await updateAccessToken(newAuthToken);
        return newAuthToken;
      } else {
        print(
            'Error: Failed to refresh token. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return null;
    }
  }
}
