import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/constants/app_colors.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  late YoutubePlayerController _controller;
  // Mock playlist (Lofi Girl, Study Beats)
  final List<String> _videoIds = [
    'jfKfPfyJRdk', // Lofi Girl
    '5qap5aO4i9A', // Lofi Hip Hop
    'DWcJFNfaw9c', // Ambient
  ];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: _videoIds.first,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: true,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // YoutubePlayerBuilder handles full screen transitions automatically
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.primary,
        onReady: () {},
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Center(
                    child: player,
                  ),
                ),
                _buildPlaylist(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context), 
            icon: Icon(Icons.arrow_back, color: Colors.white)
          ),
          Text(
            "LearnTube", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
          ),
          SizedBox(width: 48), // Balance
        ],
      ),
    );
  }

  Widget _buildPlaylist() {
    return Container(
      height: 150,
      color: Color(0xFF1A1A1A),
      child: ListView.separated(
        padding: EdgeInsets.all(16),
        scrollDirection: Axis.horizontal,
        itemCount: _videoIds.length + 1, // +1 for Add button
        separatorBuilder: (_, __) => SizedBox(width: 16),
        itemBuilder: (ctx, index) {
          if (index == _videoIds.length) {
            return _buildAddButton();
          }
          final id = _videoIds[index];
          final isPlaying = _controller.initialVideoId == id;
          return InkWell(
            onTap: () {
              _controller.load(id);
              // Force rebuild to update borders (though YoutubePlayerController might notifylisteners)
              setState(() {});
            },
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage('https://img.youtube.com/vi/$id/0.jpg'),
                  fit: BoxFit.cover,
                ),
                border: isPlaying ? Border.all(color: AppColors.primary, width: 2) : null,
              ),
              child: Center(
                child: Icon(Icons.play_circle_fill, color: Colors.white.withOpacity(0.8), size: 40),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: _showAddVideoDialog,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.primary, size: 32),
            SizedBox(height: 8),
            Text("Add Video", style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showAddVideoDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF1A1A1A),
        title: Text("Add YouTube Video", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: textController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Paste YouTube URL here",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final url = textController.text;
              final id = YoutubePlayer.convertUrlToId(url);
              if (id != null) {
                setState(() {
                  _videoIds.add(id);
                });
                Navigator.pop(ctx);
              }
            },
            child: Text("Add", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
