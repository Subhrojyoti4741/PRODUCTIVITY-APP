import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/task_model.dart';
import '../../../core/services/task_provider.dart';
import '../services/daily_planning_service.dart';
import '../../tasks/screens/create_task_screen.dart';

class DailyPlanningScreen extends StatefulWidget {
  const DailyPlanningScreen({super.key});

  @override
  State<DailyPlanningScreen> createState() => _DailyPlanningScreenState();
}

class _DailyPlanningScreenState extends State<DailyPlanningScreen> {
  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().tasks;
    final todayTasks = tasks.where((t) => isToday(t.startTime)).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 24),
              Icon(Icons.wb_sunny, size: 60, color: Colors.orangeAccent),
              SizedBox(height: 16),
              Text(
                "Good Morning!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                "Plan your day to unlock your phone.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 32),
              
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: todayTasks.isEmpty 
                    ? Center(child: Text("No tasks for today yet.", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: todayTasks.length,
                        itemBuilder: (ctx, index) {
                          final task = todayTasks[index];
                          return ListTile(
                            title: Text(task.title, style: TextStyle(color: Colors.white)),
                            subtitle: Text(task.category, style: TextStyle(color: Colors.grey)),
                            leading: Icon(Icons.circle, size: 12, color: AppColors.primary),
                          );
                        },
                      ),
                ),
              ),
              
              SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CreateTaskScreen()));
                },
                icon: Icon(Icons.add),
                label: Text("Add Task"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: todayTasks.isEmpty 
                  ? null 
                  : () async {
                      await DailyPlanningService().markPlanningComplete();
                      if (context.mounted) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Finish Planning & Unlock", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}
