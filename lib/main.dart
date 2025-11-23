import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'services/video_service.dart';
import 'services/storage_service.dart';

void main() {
  runApp(VideoPlayApp());
}

class VideoPlayApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Play App',
      theme: ThemeData.dark(),
      home: VideoPlayerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final VideoService _videoService = VideoService();
  final StorageService _storageService = StorageService();
  bool _isLoading = true;
  String _errorMessage = '';
  bool _showControls = true;
  Timer? _controlsTimer;

  Timer? _jsonCheckTimer;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _setupControlsAutoHide();
    _startJsonMonitoring();
  }
  void _startJsonMonitoring() {
    // Check for JSON changes every 10 seconds
    _jsonCheckTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if (!mounted) return;

      final hasChanged = await _storageService.hasJsonInstructionsChanged();
      if (hasChanged) {
        print('JSON instructions changed - reloading...');
        await _reloadInstructions();
      }
    });
  }
  Future<void> _reloadInstructions() async {
    try {
      final newInstructions = await _storageService.loadJsonInstructions();
      if (newInstructions != null) {
        await _videoService.updatePlaylist(newInstructions);
        await _storageService.saveLastInstruction(newInstructions);
        print('Successfully updated playlist with new instructions');
      }
    } catch (e) {
      print('Error reloading instructions: $e');
    }
  }

  void _setupControlsAutoHide() {
    _hideControlsAfterDelay();
  }

  void _hideControlsAfterDelay() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _hideControlsAfterDelay();
  }

  Future<void> _initializeApp() async {
    try {
      // Set up state change listener first
      _videoService.setOnStateChanged(() {
        if (mounted) {
          setState(() {});
        }
      });

      // Try to load new JSON instructions first
      final newInstructions = await _storageService.loadJsonInstructions();

      if (newInstructions != null) {
        await _videoService.initializePlaylist(newInstructions);
        await _storageService.saveLastInstruction(newInstructions);
        setState(() {
          _isLoading = false;
        });
      } else {
        // Fall back to last saved instructions
        final lastInstruction = await _storageService.getLastInstruction();
        if (lastInstruction != null) {
          await _videoService.initializePlaylist(lastInstruction);
          setState(() {
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'No instructions available. Please check assets/instructions.json';
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error initializing app: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? _buildLoadingScreen()
          : _errorMessage.isNotEmpty
          ? _buildErrorScreen()
          : _videoService.currentController?.value.isInitialized == true
          ? _buildVideoPlayer()
          : _buildErrorScreen(message: 'Video not initialized'),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 20),
          Text(
            'Loading Videos...',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen({String? message}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 64),
            SizedBox(height: 20),
            Text(
              'Error',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              message ?? _errorMessage,
              style: TextStyle(color: Colors.white60),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializeApp,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final controller = _videoService.currentController;

    if (controller == null || !controller.value.isInitialized) {
      return _buildErrorScreen(message: 'Video controller not ready');
    }

    return GestureDetector(
      onTap: _showControlsTemporarily,
      child: Stack(
        children: [
          // Video player
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),

          // Controls overlay
          if (_showControls) _buildControlsOverlay(controller),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay(VideoPlayerController controller) {
    return Container(
      color: Colors.black38,
      child: Stack(
        children: [
          // Play/Pause button in center
          Positioned.fill(
            child: Center(
              child: IconButton(
                icon: Icon(
                  _videoService.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: Colors.white.withOpacity(0.8),
                  size: 60,
                ),
                onPressed: _togglePlayPause,
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  // Play/Pause button
                  IconButton(
                    icon: Icon(
                      _videoService.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                  SizedBox(width: 16),

                  // Video position and duration
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          _formatDuration(controller.value.position),
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: VideoProgressIndicator(
                            controller,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: Colors.red,
                              bufferedColor: Colors.grey,
                              backgroundColor: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _togglePlayPause() async {
    if (_videoService.isPlaying) {
      await _videoService.pause();
    } else {
      await _videoService.play();
    }
    _showControlsTemporarily();
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _jsonCheckTimer?.cancel();
    _controlsTimer?.cancel();
    _videoService.dispose();
    super.dispose();
  }
}