package com.example.focus_guard

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.content.Intent
import android.content.Context
import android.util.Log

class FocusAccessibilityService : AccessibilityService() {

    private val TAG = "FocusAccessibilityService"
    // Mock blocked list for MVP - In real app, read from SharedPrefs or DB
    private val blockedPackages = listOf(
        "com.instagram.android",
        "com.facebook.katana",
        "com.zhiliaoapp.musically", // TikTok
        "com.twitter.android",
        "com.google.android.youtube"
    )

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "Service Connected")
    }

    private var lastBlockedTime: Long = 0
    private val BLOCK_COOLDOWN_MS = 1500 // Don't spam block screen
    
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString()
            
            // Critical Sanity Checks
            if (packageName.isNullOrEmpty()) return 
            if (packageName == this.packageName) return // Never block self (redundant but safe)

            if (BlockingManager.isAppBlocked(packageName)) {
                val now = System.currentTimeMillis()
                if (now - lastBlockedTime < BLOCK_COOLDOWN_MS) {
                    return // Debounce
                }
                
                Log.d(TAG, "Blocking Detected: $packageName")
                lastBlockedTime = now
                
                performGlobalAction(GLOBAL_ACTION_HOME)
                
                // Launch Flutter "Blocked" screen
                val i = Intent(this, MainActivity::class.java)
                i.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                i.action = Intent.ACTION_RUN
                i.putExtra("BLOCKED_ACTIVITY", true)
                startActivity(i)
            }
        }
    }

    private fun isAppBlocked(packageName: String): Boolean {
        // Deprecated mock logic, now handled by BlockingManager directly in loop
        return false
    }

    override fun onInterrupt() {
        Log.d(TAG, "Service Interrupted")
    }
}
