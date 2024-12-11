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
  List<Map<String, String>> _accounts = [];
  String? _email;

  @override
  void initState() {
    super.initState();
  }

  /// Fetch accounts and update the UI
  Future<void> _fetchAccounts() async {
    setState(() {
      _status = "Fetching accounts...";
    });

    try {
      final accounts = await AccountUnifierPlugin.getAccounts();
      setState(() {
        _accounts = accounts;
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
        "authToken123",
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Status: $_status",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 20),
              if (_accounts.isNotEmpty) ...[
                const Text(
                  "Accounts:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ..._accounts.map(
                  (account) => Text(
                    "Email: ${account["accountName"]}, Token: ${account["authToken"]}, Refresh: ${account["refreshToken"]}",
                  ),
                ),
              ],
              if (_email != null) ...[
                const SizedBox(height: 20),
                Text(
                  "Email: $_email",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}