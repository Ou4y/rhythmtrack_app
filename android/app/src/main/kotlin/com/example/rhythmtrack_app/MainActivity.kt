package com.example.rhythmtrack_app

import android.content.Intent
import android.provider.Settings
import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.graphics.Bitmap
import android.graphics.Canvas
import android.util.Base64

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

                "getUsageToday" -> {
                    val usageList = getUsageStatsToday()
                    result.success(usageList)
                }

                "getInstalledApps" -> {
                    val apps = getInstalledApps()
                    result.success(apps)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun openUsageAccessSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun isUsagePermissionGranted(): Boolean {
        val appOps = getSystemService(APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            "android:get_usage_stats",
            android.os.Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun getUsageStatsToday(): List<Map<String, Any>> {
        val usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val endTime = System.currentTimeMillis()
        val startTime = endTime - 24 * 60 * 60 * 1000

        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )

        val result = mutableListOf<Map<String, Any>>()

        for (stat in stats) {
            if (stat.totalTimeInForeground > 0) {
                result.add(
                    mapOf(
                        "packageName" to stat.packageName,
                        "totalTimeMs" to stat.totalTimeInForeground
                    )
                )
            }
        }

        return result
    }

    private fun getInstalledApps(): List<Map<String, Any>> {
        val pm = packageManager
        val apps = pm.getInstalledApplications(0)
        val result = mutableListOf<Map<String, Any>>()

        for (app in apps) {
            val packageName = app.packageName
            val label = pm.getApplicationLabel(app).toString()

            val drawable = pm.getApplicationIcon(app)
            val bitmap = Bitmap.createBitmap(
                drawable.intrinsicWidth,
                drawable.intrinsicHeight,
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)

            val outputStream = java.io.ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            val iconBase64 = Base64.encodeToString(outputStream.toByteArray(), Base64.NO_WRAP)

            result.add(
                mapOf(
                    "packageName" to packageName,
                    "appName" to label,
                    "iconBase64" to iconBase64
                )
            )
        }
        return result
    }
}