package com.example.account_unifier_plugin

import android.content.ContentValues
import android.content.Context
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AccountUnifierPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var context: Context
    private lateinit var channel: MethodChannel

    companion object {
        private const val TAG = "AccountUnifierPlugin"
        private const val PROVIDER_URI = "content://com.leywin.accountunifier.provider/accounts"
        private const val COLUMN_ACCOUNT_NAME = "accountName"
        private const val COLUMN_AUTH_TOKEN = "authToken"
        private const val COLUMN_REFRESH_TOKEN = "refreshToken"
        private const val COLUMN_JSON_DATA = "jsonData"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "account_unifier_plugin")
        channel.setMethodCallHandler(this)
        Log.d(TAG, "Plugin attached to engine")
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getAccounts" -> handleGetAccounts(result)
            "addAccount" -> handleAddAccount(call, result)
            "getEmail" -> handleGetEmail(result)
            "updateAccessToken" -> handleUpdateAccessToken(call, result)
            "isPackageInstalled" -> isPackageInstalled(result)
            "getJsonText" -> handleGetJsonText(result)
            "insertJsonText" -> handleInsertJsonText(call, result)
            else -> {
                Log.w(TAG, "Method not implemented: ${call.method}")
                result.notImplemented()
            }
        }
    }

    private fun handleGetJsonText(result: MethodChannel.Result) {
        Log.d(TAG, "Fetching JSON text")
        val jsonText = getJsonText()
        if (jsonText != null) {
            Log.d(TAG, "JSON text fetched: $jsonText")
            result.success(jsonText)
        } else {
            Log.w(TAG, "No JSON text found")
            result.success(null)
        }
    }

    private fun handleInsertJsonText(call: MethodCall, result: MethodChannel.Result) {
        val jsonText = call.argument<String>("jsonText")

        if (jsonText != null) {
            Log.d(TAG, "Inserting JSON text: $jsonText")
            val success = insertJsonText(jsonText)
            Log.d(TAG, "Insert JSON text result: $success")
            result.success(success)
        } else {
            Log.e(TAG, "Invalid arguments: jsonText is null")
            result.error("INVALID_ARGUMENTS", "jsonText is missing", null)
        }
    }

    private fun getJsonText(): String? {
        val uri = Uri.parse(PROVIDER_URI)
        var jsonText: String? = null

        Log.d(TAG, "Querying ContentProvider for JSON text at $uri")
        val cursor: Cursor? = try {
            context.contentResolver.query(uri, arrayOf(COLUMN_JSON_DATA), null, null, null)
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException while querying ContentProvider: ${e.message}")
            return null
        } catch (e: Exception) {
            Log.e(TAG, "Exception while querying ContentProvider: ${e.message}")
            return null
        }

        cursor?.use {
            if (it.moveToFirst()) {
                jsonText = it.getString(it.getColumnIndexOrThrow(COLUMN_JSON_DATA))
            }
        } ?: Log.w(TAG, "Cursor is null, no JSON text found")

        return jsonText
    }

    private fun insertJsonText(jsonText: String): Boolean {
        val uri = Uri.parse(PROVIDER_URI)

        Log.d(TAG, "Inserting or replacing JSON text at $uri")
        return try {
            val values = ContentValues().apply {
                put(COLUMN_JSON_DATA, jsonText)
            }

            val rowsUpdated = context.contentResolver.update(uri, values, null, null)
            if (rowsUpdated > 0) {
                Log.d(TAG, "JSON text updated successfully")
                true
            } else {
                Log.d(TAG, "No rows updated, attempting insert")
                val resultUri = context.contentResolver.insert(uri, values)
                if (resultUri != null) {
                    Log.d(TAG, "JSON text inserted successfully: $resultUri")
                    true
                } else {
                    Log.e(TAG, "Failed to insert JSON text. Insert returned null.")
                    false
                }
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException while inserting/updating JSON text: ${e.message}")
            false
        } catch (e: Exception) {
            Log.e(TAG, "Exception while inserting/updating JSON text: ${e.message}")
            false
        }
    }

    private fun isPackageInstalled(result: MethodChannel.Result) {
        try {
            val packageManager = context.packageManager
            packageManager.getPackageInfo("com.leywin.accountunifier", 0)
            result.success(true)
        } catch (e: PackageManager.NameNotFoundException) {
            result.success(false)
        } catch (e: Exception) {
            result.error("ERROR", "An unexpected error occurred: ${e.message}", null)
        }
    }


    private fun handleGetAccounts(result: MethodChannel.Result) {
        Log.d(TAG, "Fetching accounts")
        val accounts = getAccounts()
        Log.d(TAG, "Accounts fetched: $accounts")
        result.success(accounts)
    }

    private fun handleAddAccount(call: MethodCall, result: MethodChannel.Result) {
        val username = call.argument<String>("username")
        val authToken = call.argument<String>("authToken")
        val refreshToken = call.argument<String>("refreshToken")

        Log.d(
            TAG,
            "Adding account with username: $username, authToken: $authToken, refreshToken: $refreshToken"
        )

        if (username != null && authToken != null && refreshToken != null) {
            val success = addAccount(username, authToken, refreshToken)
            Log.d(TAG, "Add account result: $success")
            result.success(success)
        } else {
            Log.e(TAG, "Invalid arguments: username, authToken, or refreshToken is null")
            result.error(
                "INVALID_ARGUMENTS",
                "Username, authToken, or refreshToken is missing",
                null
            )
        }
    }

    private fun handleGetEmail(result: MethodChannel.Result) {
        Log.d(TAG, "Fetching email")
        val email = getEmail()
        if (email != null) {
            Log.d(TAG, "Email fetched: $email")
            result.success(email)
        } else {
            Log.w(TAG, "No email found")
            result.error("NO_ACCOUNT", "No account found", null)
        }
    }

    private fun handleUpdateAccessToken(call: MethodCall, result: MethodChannel.Result) {
        val authToken = call.argument<String>("authToken")
        if (authToken != null) {
            val success = updateAccessToken(authToken)
            Log.d(TAG, "Update accessToken result: $success")
            result.success(success)
        } else {
            Log.e(TAG, "Invalid arguments: authToken is null")
            result.error("INVALID_ARGUMENTS", "authToken is missing", null)
        }
    }

    private fun getAccounts(): List<Map<String, String>> {
        val uri = Uri.parse(PROVIDER_URI)
        val accounts = mutableListOf<Map<String, String>>()

        Log.d(TAG, "Querying ContentProvider at $uri")
        val cursor: Cursor? = try {
            context.contentResolver.query(uri, null, null, null, null)
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException while querying ContentProvider: ${e.message}")
            return accounts
        } catch (e: Exception) {
            Log.e(TAG, "Exception while querying ContentProvider: ${e.message}")
            return accounts
        }

        cursor?.use {
            if (it.moveToFirst()) {
                val accountName = it.getString(it.getColumnIndexOrThrow(COLUMN_ACCOUNT_NAME))
                val authToken = it.getString(it.getColumnIndexOrThrow(COLUMN_AUTH_TOKEN))
                val refreshToken = it.getString(it.getColumnIndexOrThrow(COLUMN_REFRESH_TOKEN))
                accounts.add(
                    mapOf(
                        "accountName" to accountName,
                        "authToken" to authToken,
                        "refreshToken" to refreshToken
                    )
                )
            }
        } ?: Log.w(TAG, "Cursor is null, no accounts found")

        return accounts
    }

    private fun addAccount(username: String, authToken: String, refreshToken: String): Boolean {
        val uri = Uri.parse(PROVIDER_URI)
        val values = ContentValues().apply {
            put(COLUMN_ACCOUNT_NAME, username)
            put(COLUMN_AUTH_TOKEN, authToken)
            put(COLUMN_REFRESH_TOKEN, refreshToken)
        }

        Log.d(TAG, "Inserting account to ContentProvider at $uri")
        return try {
            val resultUri = context.contentResolver.insert(uri, values)
            if (resultUri != null) {
                Log.d(TAG, "Account added successfully: $resultUri")
                true
            } else {
                Log.e(TAG, "Failed to add account. Insert returned null.")
                false
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException while inserting account: ${e.message}")
            false
        } catch (e: Exception) {
            Log.e(TAG, "Exception while inserting account: ${e.message}")
            false
        }
    }

    private fun getEmail(): String? {
        val accounts = getAccounts()
        return if (accounts.isNotEmpty()) {
            accounts[0]["accountName"]
        } else {
            null
        }
    }

    private fun updateAccessToken(authToken: String): Boolean {
        val uri = Uri.parse(PROVIDER_URI)
        val values = ContentValues().apply {
            put(COLUMN_AUTH_TOKEN, authToken)
        }

        Log.d(TAG, "Updating accessToken in ContentProvider at $uri")
        return try {
            val rowsUpdated = context.contentResolver.update(uri, values, null, null)
            if (rowsUpdated > 0) {
                Log.d(TAG, "AccessToken updated successfully")
                true
            } else {
                Log.e(TAG, "Failed to update AccessToken. No rows updated.")
                false
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException while updating accessToken: ${e.message}")
            false
        } catch (e: Exception) {
            Log.e(TAG, "Exception while updating accessToken: ${e.message}")
            false
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        Log.d(TAG, "Plugin detached from engine")
    }
}
