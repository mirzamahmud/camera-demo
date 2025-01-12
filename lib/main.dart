import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:video_player/video_player.dart';

class MyWidget extends StatefulWidget {
  final double videoSpeed;
  final String videoSrc;
  const MyWidget({required this.videoSpeed, required this.videoSrc, super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
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
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Camera example home widget.
class CameraExampleHome extends StatefulWidget {
  /// Default Constructor
  const CameraExampleHome({super.key});

  @override
  State<CameraExampleHome> createState() {
    return _CameraExampleHomeState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
}

class _CameraExampleHomeState extends State<CameraExampleHome> {
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;
  bool isShowSpeed = false;
  bool isPhoto = false;
  bool isFifteenSec = false;
  bool isSixtySec = false;
  bool isRecording = false;
  double progress = 0.0;
  Timer? timer;
  int currentCameraIndex = 0;

  List<double> videoSpeed = [2.0, 1.5, 1, 0.5, 0.25];
  double selectedVideoSpeed = -1;

  @override
  void initState() {
    super.initState();
    isPhoto = true;
    initializeCamera();
  }

  Future<void> switchCamera() async {
    currentCameraIndex = (currentCameraIndex + 1) % (_cameras.length);
    await controller?.dispose();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    _cameras = await availableCameras();
    controller =
        CameraController(_cameras[currentCameraIndex], ResolutionPreset.high);

    await controller?.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
    timer?.cancel();
  }

  // ========================== start video recording ==========================
  Future<void> _startVideoRecording() async {
    try {
      await controller?.startVideoRecording();
      setState(() {
        isRecording = true;
        progress = 0.0;
      });

      // Start progress timer for 15 seconds
      timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          progress += 0.1 / 15; // Increment progress
          if (progress >= 1.0) {
            progress = 1.0;
            timer.cancel();
          }
        });
      });

      // Stop recording after 15 seconds
      Future.delayed(const Duration(seconds: 15), () async {
        if (isRecording) {
          await _stopVideoRecording();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _startSixtySecVideoRecording() async {
    try {
      await controller?.startVideoRecording();
      setState(() {
        isRecording = true;
        progress = 0.0;
      });

      // Start progress timer for 15 seconds
      timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          progress += 0.1 / 60; // Increment progress
          if (progress >= 1.0) {
            progress = 1.0;
            timer.cancel();
          }
        });
      });

      // Stop recording after 15 seconds
      Future.delayed(const Duration(seconds: 60), () async {
        if (isRecording) {
          await _stopVideoRecording();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stopVideoRecording() async {
    try {
      videoFile = await controller?.stopVideoRecording();
      setState(() {
        isRecording = false;
        progress = 0.0;
        timer?.cancel();
      });
    } catch (e) {}
  }

  // =============================== capture photo =============================
  Future<void> capturePhoto() async {
    if (controller!.value.isInitialized) {
      try {
        final image = await controller?.takePicture();
        setState(() {
          imageFile = image;
        });
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  // =============================== toggle flash ==============================
  bool isFlashOn = false;

  Future<void> toggleFlash() async {
    try {
      if (isFlashOn) {
        await controller?.setFlashMode(FlashMode.off);
      } else {
        await controller?.setFlashMode(FlashMode.torch);
      }
      setState(() {
        isFlashOn = !isFlashOn;
      });
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
              onPressed: () {},
              icon:
                  const Icon(Icons.arrow_back, color: Colors.white, size: 24)),
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings, color: Colors.white, size: 24))
          ],
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Expanded(
                  child: CameraPreview(controller!),
                ),
              ],
            ),
            Positioned(
              right: 16,
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    isShowSpeed
                        ? Row(
                            children: [
                              Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                    vertical: 2, horizontal: 2),
                                decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  children:
                                      List.generate(videoSpeed.length, (index) {
                                    final speed = videoSpeed[index];
                                    return TextButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedVideoSpeed = speed;
                                            isShowSpeed = false;
                                          });
                                        },
                                        child: speed == 1.0
                                            ? const Text('Normal',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white))
                                            : Text('${speed}x',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    color: Colors.white)));
                                  }),
                                ),
                              ),
                              const SizedBox(width: 8)
                            ],
                          )
                        : const SizedBox(),
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                          vertical: 2, horizontal: 2),
                      decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: () {
                              switchCamera();
                            },
                            icon: const Icon(Icons.recycling,
                                size: 20, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          IconButton(
                            onPressed: () {
                              toggleFlash();
                            },
                            icon: isFlashOn
                                ? const Icon(Icons.flash_on_outlined,
                                    size: 20, color: Colors.amber)
                                : const Icon(Icons.flash_off_outlined,
                                    size: 20, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isShowSpeed = !isShowSpeed;
                              });
                            },
                            icon: isShowSpeed
                                ? const Icon(Icons.speed_outlined,
                                    size: 20, color: Colors.teal)
                                : const Icon(Icons.speed_outlined,
                                    size: 20, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        bottomNavigationBar: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            padding: const EdgeInsetsDirectional.symmetric(
              vertical: 16,
            ),
            decoration: const BoxDecoration(color: Colors.black54),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            isSixtySec = true;
                          });
                          if (isSixtySec) {
                            isFifteenSec = false;
                            isPhoto = false;
                          }
                        },
                        child: Text(
                          '60 SEC',
                          textAlign: TextAlign.center,
                          style: isSixtySec
                              ? const TextStyle(
                                  color: Colors.amber, fontSize: 16)
                              : const TextStyle(
                                  color: Colors.white, fontSize: 16),
                        )),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            isFifteenSec = true;
                          });
                          if (isFifteenSec) {
                            isSixtySec = false;
                            isPhoto = false;
                          }
                        },
                        child: Text(
                          '15 SEC',
                          textAlign: TextAlign.center,
                          style: isFifteenSec
                              ? const TextStyle(
                                  color: Colors.amber, fontSize: 16)
                              : const TextStyle(
                                  color: Colors.white, fontSize: 16),
                        )),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            isPhoto = true;
                          });
                          if (isPhoto) {
                            isSixtySec = false;
                            isFifteenSec = false;
                          }
                        },
                        child: Text(
                          'PHOTO',
                          textAlign: TextAlign.center,
                          style: isPhoto
                              ? const TextStyle(
                                  color: Colors.amber, fontSize: 16)
                              : const TextStyle(
                                  color: Colors.white, fontSize: 16),
                        ))
                  ],
                ),
                const SizedBox(height: 20),
                // ================= capture button ============================
                isPhoto
                    ? GestureDetector(
                        onTap: () {
                          capturePhoto();
                        },
                        child: Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 4)),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 50),
                            child: SizedBox(
                              child: CircularPercentIndicator(
                                radius: 40.0,
                                lineWidth: 5.0,
                                percent: progress,
                                progressColor: Colors.red,
                                center: GestureDetector(
                                  onTap: () async {
                                    if (isFifteenSec) {
                                      await _startVideoRecording();
                                    } else {
                                      await _startSixtySecVideoRecording();
                                    }
                                  },
                                  child: Container(
                                    height: 56,
                                    width: 56,
                                    decoration: const BoxDecoration(
                                        color: Colors.cyan,
                                        shape: BoxShape.circle),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => MyWidget(
                                            videoSpeed: selectedVideoSpeed,
                                            videoSrc: videoFile?.path ?? '')));
                              },
                              icon: const Icon(Icons.done,
                                  size: 24, color: Colors.white))
                        ],
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraExampleHome(),
    );
  }
}

List<CameraDescription> _cameras = <CameraDescription>[];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const CameraApp());
}
