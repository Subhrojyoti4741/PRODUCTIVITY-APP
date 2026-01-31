import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/screens/login_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/task_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<TaskProvider>().user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F231F),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                   CircleAvatar(
                     radius: 40,
                     backgroundColor: AppColors.primary.withOpacity(0.2),
                     child: Icon(Icons.person, size: 40, color: AppColors.primary),
                   ),
                   const SizedBox(height: 16),
                   Text(user.username, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                   const SizedBox(height: 4),
                   Text("Level ${user.level} • Productive Pro", style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text("CONTACT DETAILS", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            _buildInfoTile(context, Icons.phone, "Phone Number", user.phone),
            const SizedBox(height: 12),
            _buildInfoTile(context, Icons.email, "Email Address", user.email),
            const SizedBox(height: 12),
            _buildInfoTile(context, Icons.fingerprint, "User ID", "#${user.id?.toString().padLeft(6, '0')}"),
            
            const SizedBox(height: 32),
            
            const Text("APP SETTINGS", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
             _buildSettingTile(context, Icons.notifications, "Notifications", "On"),
             const SizedBox(height: 12),
             _buildSettingTile(context, Icons.dark_mode, "Theme", "Dark Mode"),
             const SizedBox(height: 12),
             _buildSettingTile(context, Icons.info_outline, "Version", "1.0.0 (Beta)"),
             
             const SizedBox(height: 32),
             
             SizedBox(
               width: double.infinity,
               child: ElevatedButton.icon(
                 onPressed: () async {
                   await Supabase.instance.client.auth.signOut();
                   if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false
                      );
                   }
                 },
                 icon: Icon(Icons.logout, color: Colors.white),
                 label: Text("Log Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.red.withOpacity(0.8),
                   padding: EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 ),
               ),
             ),
             SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, IconData icon, String title, String trailing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white))),
          Text(trailing, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
