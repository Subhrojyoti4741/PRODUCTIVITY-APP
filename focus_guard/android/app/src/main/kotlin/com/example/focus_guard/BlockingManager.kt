package com.example.focus_guard

object BlockingManager {
    private var isBlockingActive = false
    private var allowedPackages: Set<String> = emptySet()
    
    // Always allow these core apps
    private val systemAllowed = setOf(
        "com.example.focus_guard", // Self
        "com.google.android.inputmethod.latin", // Keyboard
        "com.samsung.android.honeyboard", // Samsung Keyboard
        "com.android.systemui", // System UI
        "com.android.settings", // Settings
        "com.google.android.packageinstaller",
        "com.android.vending", // Play Store
        // Essentials for "making it easier to work"
        "com.android.phone",
        "com.google.android.dialer",
        "com.samsung.android.dialer",
        "com.android.contacts",
        "com.google.android.contacts",
        "com.android.calculator2",
        "com.google.android.calculator",
        "com.google.android.deskclock",
        "com.sec.android.app.clockpackage", // Samsung Clock
        "com.google.android.calendar",
        "com.samsung.android.calendar"
    )

    fun startBlocking(allowed: List<String>) {
        allowedPackages = allowed.toSet() + systemAllowed
        isBlockingActive = true
    }

    fun stopBlocking() {
        isBlockingActive = false
        allowedPackages = emptySet()
    }

    fun isAppBlocked(packageName: String): Boolean {
        if (!isBlockingActive) return false
        // If it's in the allowed list, it's NOT blocked.
        // If it's NOT in the allowed list, it IS blocked.
        return !allowedPackages.contains(packageName)
    }
}
