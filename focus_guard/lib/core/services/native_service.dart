import 'package:flutter/services.dart';
import 'dart:async';

class NativeService {
  static const MethodChannel _channel = MethodChannel('com.example.focus_guard/native');

  static Future<bool> isAccessibilityGranted() async {
    try {
      final bool result = await _channel.invokeMethod('checkAccessibilityPermission');
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  static Future<void> requestAccessibilityPermission() async {
    try {
      await _channel.invokeMethod('requestAccessibilityPermission');
    } on PlatformException catch (_) {
      // Handle error
    }
  }

  static Future<List<Map<String, String>>> getInstalledApps() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getInstalledApps');
      // Convert List<dynamic> containing Map<dynamic, dynamic> to List<Map<String, String>>
      return result.map((e) {
        final map = Map<String, dynamic>.from(e);
        return map.map((key, value) => MapEntry(key.toString(), value.toString()));
      }).toList();
    } on PlatformException catch (_) {
      return [];
    }
  }

  static Future<void> startBlocking(List<String> allowedApps) async {
    try {
      await _channel.invokeMethod('startBlocking', {'allowedApps': allowedApps});
    } on PlatformException catch (_) {
      // Handle error
    }
  }

  static final _blockController = StreamController<void>.broadcast();
  static Stream<void> get onBlocked => _blockController.stream;

  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'showBlockedScreen') {
        _blockController.add(null);
      }
    });
  }

  static Future<void> stopBlocking() async {
    try {
      await _channel.invokeMethod('stopBlocking');
    } on PlatformException catch (_) {
      // Handle error
    }
  }

  static Future<void> requestDeviceAdminPermission() async {
    try {
      await _channel.invokeMethod('requestDeviceAdmin');
    } on PlatformException catch (_) {
      // Handle error
    }
  }

  static Future<void> updateUninstallProtection(bool allCompleted) async {
    try {
      await _channel.invokeMethod('updateUninstallProtection', {'allCompleted': allCompleted});
    } on PlatformException catch (_) {
      // Handle error
    }
  }
}
