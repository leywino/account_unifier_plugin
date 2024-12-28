import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:account_unifier_plugin/account_unifier_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = "No operation performed yet.";
  Map<String, String>? _account = {};
  String? _email;
  String? _jsonText;

  @override
  void initState() {
    super.initState();
  }

  /// Fetch JSON text
  Future<void> _fetchJsonText() async {
    setState(() {
      _status = "Fetching JSON text...";
    });

    try {
      final jsonText = await AccountUnifierPlugin.getJsonText();
      setState(() {
        _jsonText = jsonText;
        _status =
            jsonText != null ? "JSON fetched successfully!" : "No JSON found.";
      });
    } catch (e) {
      setState(() {
        _status = "Error fetching JSON: $e";
      });
    }
  }

  /// Insert or update JSON text
  Future<void> _insertJsonText() async {
    setState(() {
      _status = "Inserting JSON text...";
    });

    const newJsonText = {"id": 1, "gender": "male"};

    try {
      final success =
          await AccountUnifierPlugin.insertJsonText(jsonEncode(newJsonText));
      setState(() {
        _status =
            success ? "JSON inserted successfully!" : "Failed to insert JSON.";
      });
    } catch (e) {
      setState(() {
        _status = "Error inserting JSON: $e";
      });
    }
  }

  /// Fetch accounts and update the UI
  Future<void> _fetchAccounts() async {
    setState(() {
      _status = "Fetching accounts...";
    });

    try {
      final accounts = await AccountUnifierPlugin.getAccount();
      setState(() {
        _account = accounts;
        _status = "Accounts fetched successfully!";
      });
    } catch (e) {
      setState(() {
        _status = "Error fetching accounts: $e";
      });
    }
  }

  /// Add a new account and update the status
  Future<void> _addAccount() async {
    setState(() {
      _status = "Adding account...";
    });

    try {
      final success = await AccountUnifierPlugin.addAccount(
        "user@example.com",
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzM2NjY4ODMxLCJpYXQiOjE3MzUzNzI4MzEsImp0aSI6IjVlY2U3MmViMTk2MDQ1MzZiOGQxY2Y1MmMzOTZhMjU0IiwidXNlcl9pZCI6OSwidXNlcl90eXBlIjoic3R1ZGVudCIsImlkIjo5fQ.GUGX_JJzYnbP6yETQLBuScbwIWGSrjisHrGo-wxYKeA",
        "refreshToken123",
      );
      setState(() {
        _status =
            success ? "Account added successfully!" : "Failed to add account.";
      });
    } catch (e) {
      setState(() {
        _status = "Error adding account: $e";
      });
    }
  }

  /// Fetch the email of the stored account
  Future<void> _fetchEmail() async {
    setState(() {
      _status = "Fetching email...";
    });

    try {
      final email = await AccountUnifierPlugin.getEmail();
      setState(() {
        _email = email;
        _status = email != null ? "Email fetched: $email" : "No email found.";
      });
    } catch (e) {
      setState(() {
        _status = "Error fetching email: $e";
      });
    }
  }

  /// Update the access token for the stored account
  Future<void> _updateAccessToken() async {
    setState(() {
      _status = "Updating access token...";
    });

    try {
      final success = await AccountUnifierPlugin.updateAccessToken(
        "newAccessToken456",
      );
      setState(() {
        _status = success
            ? "Access token updated successfully!"
            : "Failed to update access token.";
      });
    } catch (e) {
      setState(() {
        _status = "Error updating access token: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Account Unifier Plugin Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Status: $_status",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchAccounts,
                  child: const Text("Fetch Accounts"),
                ),
                ElevatedButton(
                  onPressed: _addAccount,
                  child: const Text("Add Account"),
                ),
                ElevatedButton(
                  onPressed: _fetchEmail,
                  child: const Text("Fetch Email"),
                ),
                ElevatedButton(
                  onPressed: _updateAccessToken,
                  child: const Text("Update Access Token"),
                ),
                ElevatedButton(
                  onPressed: _fetchJsonText,
                  child: const Text("Fetch JSON Text"),
                ),
                ElevatedButton(
                  onPressed: _insertJsonText,
                  child: const Text("Insert JSON Text"),
                ),
                const SizedBox(height: 20),
                if (_account != null) ...[
                  const Text(
                    "Accounts:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Email: ${_account!["accountName"]}, Token: ${_account!["authToken"]}, Refresh: ${_account!["refreshToken"]}",
                  ),
                ],
                if (_email != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    "Email: $_email",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
                if (_jsonText != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    "JSON: $_jsonText",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
