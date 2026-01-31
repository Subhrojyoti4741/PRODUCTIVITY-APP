import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const int _focusTime = 25 * 60; // 25 minutes
  static const int _breakTime = 5 * 60;  // 5 minutes

  int _timeLeft = _focusTime;
  bool _isFocusMode = true;
  bool _isRunning = false;
  Timer? _timer;

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          setState(() => _timeLeft--);
        } else {
          _timer?.cancel();
          _isRunning = false;
          _showCompletionDialog();
        }
      });
    }
    setState(() => _isRunning = !_isRunning);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _timeLeft = _isFocusMode ? _focusTime : _breakTime;
    });
  }

  void _switchMode() {
    _timer?.cancel();
    setState(() {
      _isFocusMode = !_isFocusMode;
      _timeLeft = _isFocusMode ? _focusTime : _breakTime;
      _isRunning = false;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(_isFocusMode ? "Focus Completed!" : "Break Over!", style: const TextStyle(color: Colors.white)),
        content: Text(
          _isFocusMode ? "Great job! Take a short break." : "Ready to get back to work?",
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _switchMode();
            },
            child: const Text("OK", style: TextStyle(color: AppColors.primary)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerString {
    final minutes = (_timeLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timeLeft % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  double get _progress {
    final total = _isFocusMode ? _focusTime : _breakTime;
    return _timeLeft / total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F231F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Pomodoro Timer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isFocusMode ? AppColors.primary.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _isFocusMode ? AppColors.primary.withOpacity(0.3) : Colors.amber.withOpacity(0.3)),
              ),
              child: Text(
                _isFocusMode ? "FOCUS MODE" : "BREAK MODE",
                style: TextStyle(
                  color: _isFocusMode ? AppColors.primary : Colors.amber,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 48),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 20,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    color: _isFocusMode ? AppColors.primary : Colors.amber,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  _timerString,
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 64),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton(
                  icon: _isRunning ? Icons.pause : Icons.play_arrow,
                  onTap: _toggleTimer,
                  color: AppColors.primary,
                  size: 64,
                ),
                const SizedBox(width: 24),
                _buildButton(
                  icon: Icons.refresh,
                  onTap: _resetTimer,
                  color: Colors.white,
                  size: 56,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, required VoidCallback onTap, required Color color, required double size}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Icon(icon, color: color, size: size * 0.5),
      ),
    );
  }
}
