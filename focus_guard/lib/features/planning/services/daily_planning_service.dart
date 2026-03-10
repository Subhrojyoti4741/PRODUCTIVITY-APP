import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../../core/services/native_service.dart';

class DailyPlanningService {
  static const String KEY_LAST_PLANNING_DATE = 'last_planning_date';

  /// Check if we need to enforce daily planning
  /// Returns true if locked down
  Future<bool> checkAndEnforceLockdown() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString(KEY_LAST_PLANNING_DATE);
    final now = DateTime.now();
    
    // Check if it's past midnight (e.g. any time in the new day) 
    // AND we haven't planned for this day yet.
    bool needsPlanning = false;

    if (lastDateStr == null) {
      needsPlanning = true;
    } else {
      final lastDate = DateTime.parse(lastDateStr);
      // If last planning was on a previous day (or same day but we want to strict check days)
      if (!_isSameDay(lastDate, now)) {
        needsPlanning = true;
      }
    }

    if (needsPlanning) {
      // Start blocking everything (empty allowed list)
      // EXCEPT: We rely on the allowed list containing "self" in Native code
      await NativeService.startBlocking([]); 
      return true;
    }

    return false;
  }

  Future<void> markPlanningComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_LAST_PLANNING_DATE, DateTime.now().toIso8601String());
    await NativeService.stopBlocking();
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
