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
        
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
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
                
                // 1. Add Self
                val myPackage = context.packageName
                
                // 2. Add Default Launcher (Home Screen)
                val launcherIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
                val resolveInfo = context.packageManager.resolveActivity(launcherIntent, android.content.pm.PackageManager.MATCH_DEFAULT_ONLY)
                val launcherPackage = resolveInfo?.activityInfo?.packageName
                
                // Combine all
                val fullList = allowedApps.toMutableList()
                if (myPackage != null) fullList.add(myPackage)
                if (launcherPackage != null) fullList.add(launcherPackage)
                
                BlockingManager.startBlocking(fullList)
                result.success(true)
            } else if (call.method == "stopBlocking") {
                BlockingManager.stopBlocking()
                result.success(true)
            } else if (call.method == "requestDeviceAdmin") {
                try {
                     android.util.Log.e("FocusGuard", "Simple Check: Requesting Admin")
                     
                     val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as android.app.admin.DevicePolicyManager
                     val componentName = android.content.ComponentName(context, GuardAdminReceiver::class.java)
                     
                     if (dpm.isAdminActive(componentName)) {
                         android.util.Log.e("FocusGuard", "State: Already Active")
                         android.widget.Toast.makeText(context, "Uninstall Protection is Already Active ✅", android.widget.Toast.LENGTH_SHORT).show()
                     } else {
                         android.util.Log.e("FocusGuard", "State: Not Active, Redirecting to Settings")
                         
                         // Bypass the broken system dialog and go straight to the list
                         android.widget.Toast.makeText(context, "Redirecting to Settings. Please Activate Manually.", android.widget.Toast.LENGTH_LONG).show()
                         
                         try {
                             // Try opening the specific "Device Admin Apps" list directly
                             val intent = Intent()
                             intent.setComponent(android.content.ComponentName("com.android.settings", "com.android.settings.DeviceAdminSettings"))
                             intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                             context.startActivity(intent)
                         } catch (e: Exception) {
                             // Fallback to Security Settings
                             try {
                                 val intent = Intent(Settings.ACTION_SECURITY_SETTINGS)
                                 intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                 context.startActivity(intent)
                             } catch (e2: Exception) {
                                 val intent = Intent(Settings.ACTION_SETTINGS)
                                 intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                 context.startActivity(intent)
                             }
                         }
                     }
                     
                     result.success(true)
                } catch (e: Exception) {
                     android.util.Log.e("FocusGuard", "EXCEPTION: ${e.message}")
                     e.printStackTrace()
                     android.widget.Toast.makeText(context, "Err: ${e.message}", android.widget.Toast.LENGTH_LONG).show()
                     result.error("ADMIN_ERROR", e.message, null)
                }
            } else if (call.method == "updateUninstallProtection") {
                val allCompleted = call.argument<Boolean>("allCompleted") ?: false
                val prefs = context.getSharedPreferences("FocusGuardPrefs", Context.MODE_PRIVATE)
                val editor = prefs.edit()
                
                editor.putBoolean("all_tasks_completed", allCompleted)
                
                if (allCompleted) {
                    // Set allowed uninstall time to Midnight Tonight (i.e., start of tomorrow)
                    val c = java.util.Calendar.getInstance()
                    c.add(java.util.Calendar.DAY_OF_YEAR, 1)
                    c.set(java.util.Calendar.HOUR_OF_DAY, 0)
                    c.set(java.util.Calendar.MINUTE, 0)
                    c.set(java.util.Calendar.SECOND, 0)
                    editor.putLong("earliest_uninstall_time", c.timeInMillis)
                } else {
                    editor.putLong("earliest_uninstall_time", Long.MAX_VALUE) // Never effectively
                }
                
                editor.apply()
                result.success(true)
            } else {
                result.notImplemented()
            }
        }

        // Check initial intent
        handleIntent(intent, methodChannel)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val methodChannel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
        handleIntent(intent, methodChannel)
    }

    private fun handleIntent(intent: Intent, channel: MethodChannel) {
        if (intent.getBooleanExtra("BLOCKED_ACTIVITY", false)) {
            channel.invokeMethod("showBlockedScreen", null)
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
