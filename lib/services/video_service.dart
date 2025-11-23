import 'dart:io';
import 'package:video_player/video_player.dart';
import '../models/instruction_models.dart';
import 'package:video_player/video_player.dart';
import '../models/instruction_models.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/instruction_models.dart';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/instruction_models.dart';

class VideoService {
  VideoPlayerController? _currentController;
  List<PlaylistItem> _playlist = [];
  String _playlistRepeat = 'always';
  int _currentPlaylistIndex = 0;
  int _currentFileIndex = 0;
  int _currentRepeatCount = 0;
  bool _isPlaying = false;
  VoidCallback? _onStateChanged;

  VideoPlayerController? get currentController => _currentController;
  bool get isPlaying => _isPlaying;
  bool get isInitialized => _currentController?.value.isInitialized ?? false;

  void setOnStateChanged(VoidCallback callback) {
    _onStateChanged = callback;
  }

  Future<void> initializePlaylist(InstructionData data) async {
    await _applyNewInstructions(data);
  }

  Future<void> updatePlaylist(InstructionData data) async {
    // Check if instructions are actually different
    if (_areInstructionsDifferent(data)) {
      await _applyNewInstructions(data);
    }
  }

  Future<void> _applyNewInstructions(InstructionData data) async {
    // Store current state
    final bool wasPlaying = _isPlaying;

    // Clear current playlist
    _playlist.clear();
    _currentPlaylistIndex = 0;
    _currentFileIndex = 0;
    _currentRepeatCount = 0;

    // Apply new instructions
    _playlist = List.from(data.playlist);
    _playlistRepeat = data.playlistRepeat;

    if (_playlist.isNotEmpty) {
      await _playCurrentItem();

      // Restore play state if it was playing
      if (wasPlaying && !_isPlaying) {
        await play();
      }
    } else {
      _isPlaying = false;
      _notifyStateChanged();
    }
  }

  bool _areInstructionsDifferent(InstructionData newData) {
    if (_playlistRepeat != newData.playlistRepeat) return true;
    if (_playlist.length != newData.playlist.length) return true;

    for (int i = 0; i < _playlist.length; i++) {
      final currentItem = _playlist[i];
      final newItem = newData.playlist[i];

      if (currentItem.folder != newItem.folder ||
          currentItem.adId != newItem.adId ||
          currentItem.repeat != newItem.repeat ||
          currentItem.sequence != newItem.sequence ||
          !_areListsEqual(currentItem.files, newItem.files)) {
        return true;
      }
    }

    return false;
  }

  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  // ... rest of your existing VideoService methods remain the same
  Future<void> _playCurrentItem() async {
    if (_playlist.isEmpty) return;

    final currentItem = _playlist[_currentPlaylistIndex];

    if (currentItem.files.isEmpty) {
      print('No files in playlist item');
      return;
    }

    if (_currentFileIndex >= currentItem.files.length) {
      _currentFileIndex = 0;
    }

    final filename = currentItem.files[_currentFileIndex];
    await _loadAndPlayVideo(currentItem.folder, filename);
  }

  Future<void> _loadAndPlayVideo(String folder, String filename) async {
    try {
      await _currentController?.dispose();

      final videoPath = 'assets/videos/$folder/$filename';
      print('Loading video: $videoPath');

      _currentController = VideoPlayerController.asset(videoPath);

      _currentController!.addListener(_videoListener);

      await _currentController!.initialize();
      await _currentController!.play();

      _isPlaying = true;
      _notifyStateChanged();

    } catch (e) {
      print('Error loading video: $filename - $e');
      _handleVideoError();
    }
  }

  void _videoListener() {
    if (_currentController?.value.isCompleted == true) {
      _handleVideoCompletion();
    }

    // Update UI state when video state changes
    if (_currentController?.value.isPlaying != _isPlaying) {
      _isPlaying = _currentController?.value.isPlaying ?? false;
      _notifyStateChanged();
    }
  }

  void _handleVideoCompletion() {
    final currentItem = _playlist[_currentPlaylistIndex];

    _currentFileIndex++;

    if (_currentFileIndex >= currentItem.files.length) {
      _currentRepeatCount++;
      _currentFileIndex = 0;

      if (_currentRepeatCount >= currentItem.repeat) {
        _moveToNextPlaylistItem();
      } else {
        _playCurrentItem();
      }
    } else {
      _playCurrentItem();
    }
  }

  void _handleVideoError() {
    final currentItem = _playlist[_currentPlaylistIndex];

    _currentFileIndex++;

    if (_currentFileIndex >= currentItem.files.length) {
      _currentRepeatCount++;
      _currentFileIndex = 0;

      if (_currentRepeatCount >= currentItem.repeat) {
        _moveToNextPlaylistItem();
      } else {
        _playCurrentItem();
      }
    } else {
      _playCurrentItem();
    }
  }

  void _moveToNextPlaylistItem() {
    _currentPlaylistIndex++;
    _currentRepeatCount = 0;
    _currentFileIndex = 0;

    if (_currentPlaylistIndex >= _playlist.length) {
      if (_playlistRepeat == 'always') {
        _currentPlaylistIndex = 0;
      } else {
        _isPlaying = false;
        _notifyStateChanged();
        return;
      }
    }

    _playCurrentItem();
  }

  Future<void> play() async {
    if (_currentController?.value.isInitialized == true) {
      await _currentController!.play();
      _isPlaying = true;
      _notifyStateChanged();
    }
  }

  Future<void> pause() async {
    if (_currentController?.value.isInitialized == true) {
      await _currentController!.pause();
      _isPlaying = false;
      _notifyStateChanged();
    }
  }

  void _notifyStateChanged() {
    _onStateChanged?.call();
  }

  Future<void> dispose() async {
    _currentController?.removeListener(_videoListener);
    await _currentController?.dispose();
    _currentController = null;
    _isPlaying = false;
  }
}