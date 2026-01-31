package com.example.focus_guard

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.provider.Settings
import android.content.Intent
import android.text.TextUtils
import android.accessibilityservice.AccessibilityServiceInfo
import android.view.accessibility.AccessibilityManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.focus_guard/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "checkAccessibilityPermission") {
                result.success(isAccessibilityServiceEnabled(context, FocusAccessibilityService::class.java))
            } else if (call.method == "requestAccessibilityPermission") {
                val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                startActivity(intent)
                result.success(true)
            } else if (call.method == "getInstalledApps") {
                val apps = getInstalledApps(context)
                result.success(apps)
            } else if (call.method == "startBlocking") {
                val allowedApps = call.argument<List<String>>("allowedApps") ?: listOf()
                // Also add self to allowed
                val fullList = allowedApps + context.packageName
                BlockingManager.startBlocking(fullList)
                result.success(true)
            } else if (call.method == "stopBlocking") {
                BlockingManager.stopBlocking()
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    // Helper to check if the service is enabled
    private fun isAccessibilityServiceEnabled(context: Context, service: Class<*>): Boolean {
        val am = context.getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
        val enabledServices = am.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK)
        for (enabledService in enabledServices) {
            val enabledServiceInfo = enabledService.resolveInfo.serviceInfo
            if (enabledServiceInfo.packageName == context.packageName && enabledServiceInfo.name == service.name) {
                return true
            }
        }
        return false
    }

    private fun getInstalledApps(context: Context): List<Map<String, String>> {
        val pm = context.packageManager
        val apps = pm.getInstalledPackages(0)
        val appList = mutableListOf<Map<String, String>>()

        for (app in apps) {
            // Filter out system apps if needed, but for now allow all user-launchable
            if (pm.getLaunchIntentForPackage(app.packageName) != null) {
                // applicationInfo could be null, use safe call
                val appName = app.applicationInfo?.loadLabel(pm)?.toString() ?: app.packageName
                appList.add(mapOf("name" to appName, "package" to app.packageName))
            }
        }
        // Sort alphabetically
        appList.sortBy { it["name"] }
        return appList
    }
}
