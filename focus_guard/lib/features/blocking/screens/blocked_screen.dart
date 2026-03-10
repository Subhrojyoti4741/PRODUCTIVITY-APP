import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/task_provider.dart';
import '../../../core/services/native_service.dart';
import '../../planning/services/daily_planning_service.dart';
import '../../planning/screens/daily_planning_screen.dart';

class BlockedScreen extends StatefulWidget {
  const BlockedScreen({super.key});

  @override
  State<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    // 1. Check if it's Morning Lockdown
    final needsPlanning = await DailyPlanningService().checkAndEnforceLockdown();
    if (needsPlanning && mounted) {
      // Redirect to Planning Screen
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DailyPlanningScreen()));
      return;
    }

    // 2. Check if we have an active Strict Task
    if (mounted) {
       final taskProvider = context.read<TaskProvider>();
       // We need to wait for data if not loaded? usually loaded by now.
       // Actually, let's just force sync.
       // Accessing private method is hard. Let's just use public API or allow user to exit.
       
       // Force stop if user clicks "Go Back" and no task is running, handled in button.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.redAccent),
              SizedBox(height: 24),
              Text(
                "Access Denied",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "This app is blocked until your tasks are done.\nStay focused!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 48),
              ElevatedButton(
                onPressed: () async {
                   // Smart Exit: Check if we actually SHOULD be blocked.
                   final needsPlanning = await DailyPlanningService().checkAndEnforceLockdown();
                   if (needsPlanning && mounted) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DailyPlanningScreen()));
                      return;
                   }

                   // If no planning needed, check tasks
                   if (mounted) {
                      final tasks = context.read<TaskProvider>().tasks; // Assuming loaded
                      final hasStrict = tasks.any((t) => t.isStrict && !t.isCompleted && DateTime.now().isAfter(t.startTime) && DateTime.now().isBefore(t.endTime));
                      
                      if (!hasStrict) {
                        // Emergency Unblock
                        await NativeService.stopBlocking();
                      }
                      
                      if (mounted) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                   }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Go Back to Focus", style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
