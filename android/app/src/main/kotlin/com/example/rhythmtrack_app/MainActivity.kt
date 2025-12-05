package com.example.rhythmtrack_app

import android.content.Intent
import android.provider.Settings
import android.app.AppOpsManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.rhythmtrack/usage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "openUsageSettings" -> {
                    openUsageAccessSettings()
                    result.success(true)
                }

                "checkPermissionStatus" -> {
                    val granted = isUsagePermissionGranted()
                    result.success(granted)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // Launches the Usage Access Settings screen
    private fun openUsageAccessSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    // Checks whether usage access permission is granted
    private fun isUsagePermissionGranted(): Boolean {
        val appOps = getSystemService(APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            "android:get_usage_stats",
            android.os.Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }
}