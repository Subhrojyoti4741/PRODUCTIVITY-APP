package com.example.focus_guard

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.Toast
import java.util.Calendar

class GuardAdminReceiver : DeviceAdminReceiver() {

    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
    }

    override fun onDisabled(context: Context, intent: Intent) {
        super.onDisabled(context, intent)
    }

    override fun onDisableRequested(context: Context, intent: Intent): CharSequence? {
        val prefs = context.getSharedPreferences("FocusGuardPrefs", Context.MODE_PRIVATE)
        
        // 1. Check Task Completion Status
        val allTasksCompleted = prefs.getBoolean("all_tasks_completed", false)
        
        // 2. Check Time (Must be past midnight of the day tasks were finished? Or just generally past midnight?)
        // Requirement: "It is past midnight (12:00 AM)"
        // This implies checks are strict: "Complete today's tasks" implies we are in "Today".
        // "Wait until midnight" implies "Wait until Tomorrow".
        
        // Let's rely on a timestamp set by Flutter: "earliest_uninstall_time"
        // If 0, it means conditions pending.
        val earliestUninstallTime = prefs.getLong("earliest_uninstall_time", 0)
        val now = System.currentTimeMillis()

        if (!allTasksCompleted) {
             return "Warning: You have incomplete tasks! Please complete all your tasks for today before uninstalling."
        }

        if (now < earliestUninstallTime) {
             return "Warning: You usually can't uninstall until midnight. Complete today's tasks and wait until 12:00 AM."
        }
        
        // If we really want to simulate "Prevent", we return the message. 
        // On older Android this blocks. On newer, it warns.
        // If conditions met, return null (allow).
        return null 
    }
}
