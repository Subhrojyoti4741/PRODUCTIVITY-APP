import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/task_model.dart';
import '../../../core/services/task_provider.dart';
import '../../../core/services/native_service.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  String _selectedCategory = 'Work';
  bool _isStrict = false;
  
  final List<String> _categories = ['Work', 'Study', 'Exercise', 'Mindfulness', 'Other'];

  List<Map<String, String>> _installedApps = [];
  final List<String> _selectedApps = [];
  bool _isLoadingApps = true;

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
  }

  Future<void> _loadInstalledApps() async {
    final apps = await NativeService.getInstalledApps();
    if (mounted) {
      setState(() {
        _installedApps = apps;
        _isLoadingApps = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Task"),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                style: Theme.of(context).textTheme.displaySmall,
                decoration: InputDecoration(
                  hintText: "What do you need to get done?",
                  border: InputBorder.none,
                ),
                validator: (val) => val!.isEmpty ? "Title is required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker("Start", _startTime, (val) => setState(() => _startTime = val)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePicker("End", _endTime, (val) => setState(() => _endTime = val)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 24),
              
              // Strict Mode Toggle
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isStrict ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _isStrict ? AppColors.primary : Colors.white10),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Strict Mode (App Blocking)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text(_isStrict ? "Other apps will be blocked!" : "App blocking is disabled", style: TextStyle(color: Colors.grey)),
                  value: _isStrict,
                  activeColor: AppColors.primary,
                  onChanged: (val) async {
                    if (val) {
                      // Check permission first
                      final isGranted = await NativeService.isAccessibilityGranted();
                      if (!isGranted && mounted) {
                        _showPermissionDialog();
                        return;
                      }
                    }
                    setState(() => _isStrict = val);
                  },
                ),
              ),
              
              if (_isStrict) ...[
                const SizedBox(height: 24),
                Text("Allowed Apps (Select to whitelist)", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _isLoadingApps 
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        itemCount: _installedApps.length,
                        itemBuilder: (ctx, index) {
                          final app = _installedApps[index];
                          final packageName = app['package']!;
                          final appName = app['name']!;
                          final isSelected = _selectedApps.contains(packageName);
                          
                          return CheckboxListTile(
                            title: Text(appName, style: TextStyle(color: Colors.white)),
                            subtitle: Text(packageName, style: TextStyle(color: Colors.grey, fontSize: 10)),
                            value: isSelected,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedApps.add(packageName);
                                } else {
                                  _selectedApps.remove(packageName);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
              ],
                    
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text("Create Task", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text("Permission Required", style: TextStyle(color: Colors.white)),
        content: Text("To use Strict Mode, focus focus guard needs Accessibility Permission to detect and block distraction apps.", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              NativeService.requestAccessibilityPermission();
            },
            child: Text("Enable", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, DateTime time, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(time));
        if (picked != null) {
          final now = DateTime.now();
          onPicked(DateTime(now.year, now.month, now.day, picked.hour, picked.minute));
        }
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(DateFormat('hh:mm a').format(time), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final diff = _endTime.difference(_startTime).inMinutes;
      final xp = (diff / 10).round().coerceAtLeast(10); 

      final task = Task(
        title: _titleController.text,
        description: _descController.text,
        startTime: _startTime,
        endTime: _endTime,
        category: _selectedCategory,
        allowedApps: _selectedApps,
        xpReward: xp,
        isStrict: _isStrict
      );

      context.read<TaskProvider>().addTask(task);
      Navigator.pop(context);
    }
  }
}

extension Coerce on int {
  int coerceAtLeast(int min) => this < min ? min : this;
}
