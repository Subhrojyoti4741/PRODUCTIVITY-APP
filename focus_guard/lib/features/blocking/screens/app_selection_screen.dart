import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/native_service.dart';

class AppSelectionScreen extends StatefulWidget {
  final List<String> initialSelectedPackages;
  const AppSelectionScreen({super.key, required this.initialSelectedPackages});

  @override
  State<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  List<Map<String, String>> _installedApps = [];
  Set<String> _selectedPackages = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedPackages = widget.initialSelectedPackages.toSet();
    _loadApps();
  }

  Future<void> _loadApps() async {
    final apps = await NativeService.getInstalledApps();
    if (mounted) {
      setState(() {
        _installedApps = apps;
        _isLoading = false;
      });
    }
  }

  void _onSave() {
    Navigator.of(context).pop(_selectedPackages.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Allowed Apps"),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: Text("Done", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _installedApps.length,
              itemBuilder: (context, index) {
                final app = _installedApps[index];
                final name = app['name'] ?? 'Unknown';
                final packageName = app['package'] ?? '';
                final isSelected = _selectedPackages.contains(packageName);

                return CheckboxListTile(
                  title: Text(name, style: TextStyle(color: Colors.white)),
                  subtitle: Text(packageName, style: TextStyle(color: Colors.grey, fontSize: 10)),
                  value: isSelected,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedPackages.add(packageName);
                      } else {
                        _selectedPackages.remove(packageName);
                      }
                    });
                  },
                );
              },
            ),
    );
  }
}
