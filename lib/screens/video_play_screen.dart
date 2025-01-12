import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayScreen extends StatefulWidget {
  final double videoSpeed;
  final String videoSrc;
  const VideoPlayScreen(
      {required this.videoSpeed, required this.videoSrc, super.key});

  @override
  State<VideoPlayScreen> createState() => _VideoPlayScreenState();
}

class _VideoPlayScreenState extends State<VideoPlayScreen> {
  VideoPlayerController? videoPlayerController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    videoPlayerController = VideoPlayerController.file(
      File(widget.videoSrc),
    );

    await videoPlayerController?.initialize();
    videoPlayerController?.setLooping(true); // Optional: Loop the video
    setState(() {});
    videoPlayerController?.play();

    videoPlayerController?.setPlaybackSpeed(widget.videoSpeed);
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Video Player')),
        body: videoPlayerController?.value.isInitialized ?? false
            ? Column(
                children: [
                  AspectRatio(
                    aspectRatio: videoPlayerController!.value.aspectRatio,
                    child: VideoPlayer(videoPlayerController!),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Current Speed: ${widget.videoSpeed}x",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
