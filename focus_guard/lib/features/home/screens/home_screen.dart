import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/task_provider.dart';
import '../../../core/models/task_model.dart';
import '../../../core/models/user_model.dart';
import '../../tasks/screens/create_task_screen.dart';
import '../../learning/screens/learning_screen.dart';
import '../../focus/screens/pomodoro_screen.dart';
import '../../settings/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TaskProvider>().loadData());
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final user = taskProvider.user;
    final tasks = taskProvider.tasks;

    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final totalTasks = tasks.length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    final screens = [
      SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(user),
            const SizedBox(height: 24),
            _buildProgressCard(completedTasks, totalTasks),
            const SizedBox(height: 24),
            _buildFocusZone(),
            const SizedBox(height: 24),
            _buildDailyTasksHeader(progress),
            const SizedBox(height: 12),
            _buildTaskList(tasks),
          ],
        ),
      ),
      const Center(child: Text("Stats (Coming Soon)", style: TextStyle(color: Colors.white))),
      const Center(child: Text("Focus Mode (Coming Soon)", style: TextStyle(color: Colors.white))),
      const Center(child: Text("Social (Coming Soon)", style: TextStyle(color: Colors.white))),
    ];

    return Scaffold(
      extendBody: true, // Important for blending
      body: SafeArea(
        bottom: false,
        child: screens[_selectedIndex],
      ),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTaskScreen()));
        },
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: AppColors.textLight),
      ) : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(User? user) {
    if (user == null) return const CircularProgressIndicator();
    return Row(
      children: [
         CircleAvatar(
           radius: 20,
           backgroundColor: AppColors.primary.withValues(alpha: 0.2),
           child: Icon(Icons.person, color: AppColors.primary),
         ),
         const SizedBox(width: 12),
         Expanded(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text("Hi, ${user.username}! 👋", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
               Row(
                 children: [
                   Flexible(child: Text("Level ${user.level} • Productive Pro", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w500))),
                   const SizedBox(width: 8),
                   Container(
                     padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                     decoration: BoxDecoration(color: AppColors.badgeGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                     child: Row(
                       children: [
                         Icon(Icons.military_tech, size: 14, color: Colors.amber[700]),
                         Text("${user.streak}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber[800])),
                       ],
                     ),
                   )
                 ],
               )
             ],
           )
         ),
         const SizedBox(width: 8),
         Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             IconButton(
               onPressed: (){},
               icon: Icon(Icons.notifications_outlined),
               padding: EdgeInsets.zero,
               constraints: BoxConstraints(), 
             ),
             const SizedBox(width: 16),
             IconButton(
               onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())), 
               icon: Icon(Icons.settings_outlined),
               padding: EdgeInsets.zero,
               constraints: BoxConstraints(),
             ),
           ],
         )
      ],
    );
  }

  Widget _buildProgressCard(int completed, int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: total > 0 ? completed / total : 0,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey.withValues(alpha: 0.1),
                  color: AppColors.primary,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("$completed/$total", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                      Text("TASKS DONE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text("You're on fire! 🔥 +250 XP earned today", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildFocusZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Focus Zone", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningScreen())),
              child: _buildFocusCard("LearnTube", "Distraction-free", Icons.play_circle_filled, AppColors.secondary)
            )),
            const SizedBox(width: 12),
            Expanded(child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PomodoroScreen())),
              child: _buildFocusCard("Pomodoro", "25m deep work", Icons.timer, AppColors.accent)
            )),
          ],
        )
      ],
    );
  }

  Widget _buildFocusCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDailyTasksHeader(double progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Daily Tasks", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Text("${(progress * 100).toInt()}% Complete", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary.withValues(alpha: 0.8))),
        )
      ],
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text("No tasks yet. Add one!", style: TextStyle(color: Colors.grey)),
      ));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        final task = tasks[index];
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Checkbox(
              value: task.isCompleted,
              activeColor: AppColors.primary,
              onChanged: (val) {
                if (val == true) {
                  ctx.read<TaskProvider>().completeTask(task);
                }
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            title: Text(task.title, style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey : null,
            )),
            subtitle: Text("${task.category} • Due 2:00 PM", style: TextStyle(fontSize: 10, color: Colors.grey)),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text("+${task.xpReward} XP", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
        border: Border(top: BorderSide(color: Colors.white10))
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.self_improvement_outlined), selectedIcon: Icon(Icons.self_improvement), label: 'Focus'),
          NavigationDestination(icon: Icon(Icons.group_outlined), selectedIcon: Icon(Icons.group), label: 'Social'),
        ],
      ),
    );
  }
}
