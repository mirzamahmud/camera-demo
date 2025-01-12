import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:video_player/video_player.dart';

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
  // This enum is from a different package, so a new value could be added at
  // any time. The example should keep working if that happens.
  // ignore: dead_code
  return Icons.camera;
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

class _CameraExampleHomeState extends State<CameraExampleHome>
    with SingleTickerProviderStateMixin {
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double minAvailableExposureOffset = 0.0;
  double maxAvailableExposureOffset = 0.0;
  double currentExposureOffset = 0.0;
  late AnimationController flashModeControlRowAnimationController;
  late Animation<double> flashModeControlRowAnimation;
  late AnimationController exposureModeControlRowAnimationController;
  late Animation<double> exposureModeControlRowAnimation;
  late AnimationController focusModeControlRowAnimationController;
  late Animation<double> focusModeControlRowAnimation;
  double minAvailableZoom = 1.0;
  double maxAvailableZoom = 1.0;
  double currentScale = 1.0;
  double baseScale = 1.0;
  late AnimationController progressController;

  // Counting pointers (number of user fingers on screen)
  int pointers = 0;
  bool isShowSpeed = false;
  bool isPhoto = false;
  bool isFifteenSec = false;
  bool isSixtySec = false;
  bool isRecording = false;
  double progress = 0.0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    initializeCamera();

    progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
  }

  Future<void> initializeCamera() async {
    _cameras = await availableCameras();
    controller = CameraController(_cameras[0], ResolutionPreset.high);

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

  // =============================== capture photo ================================
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
                                  children: [
                                    TextButton(
                                        onPressed: () {},
                                        child: const Text('2x',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white))),
                                    const SizedBox(height: 4),
                                    TextButton(
                                        onPressed: () {},
                                        child: const Text('1.5x',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white))),
                                    const SizedBox(height: 4),
                                    TextButton(
                                        onPressed: () {},
                                        child: const Text('Normal',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white))),
                                    const SizedBox(height: 4),
                                    TextButton(
                                        onPressed: () {},
                                        child: const Text('0.5x',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white))),
                                    const SizedBox(height: 4),
                                    TextButton(
                                        onPressed: () {},
                                        child: const Text('0.25x',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white))),
                                  ],
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
                            onPressed: () {},
                            icon: const Icon(Icons.recycling,
                                size: 20, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.flash_off_outlined,
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
                    : SizedBox(
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
                                  color: Colors.cyan, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // void _handleScaleStart(ScaleStartDetails details) {
  //   _baseScale = _currentScale;
  // }

  // Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
  //   // When there are not exactly two fingers on screen don't scale
  //   if (controller == null || _pointers != 2) {
  //     return;
  //   }

  //   _currentScale = (_baseScale * details.scale)
  //       .clamp(_minAvailableZoom, _maxAvailableZoom);

  //   await controller!.setZoomLevel(_currentScale);
  // }

  // /// Display the thumbnail of the captured image or video.
  // Widget _thumbnailWidget() {
  //   final VideoPlayerController? localVideoController = videoController;

  //   return Expanded(
  //     child: Align(
  //       alignment: Alignment.centerRight,
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: <Widget>[
  //           if (localVideoController == null && imageFile == null)
  //             Container()
  //           else
  //             SizedBox(
  //               width: 64.0,
  //               height: 64.0,
  //               child: (localVideoController == null)
  //                   ? (
  //                       // The captured image on the web contains a network-accessible URL
  //                       // pointing to a location within the browser. It may be displayed
  //                       // either with Image.network or Image.memory after loading the image
  //                       // bytes to memory.
  //                       kIsWeb
  //                           ? Image.network(imageFile!.path)
  //                           : Image.file(File(imageFile!.path)))
  //                   : Container(
  //                       decoration: BoxDecoration(
  //                           border: Border.all(color: Colors.pink)),
  //                       child: Center(
  //                         child: AspectRatio(
  //                             aspectRatio:
  //                                 localVideoController.value.aspectRatio,
  //                             child: VideoPlayer(localVideoController)),
  //                       ),
  //                     ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // /// Display a bar with buttons to change the flash and exposure modes
  // Widget _modeControlRowWidget() {
  //   return Column(
  //     children: <Widget>[
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: <Widget>[
  //           IconButton(
  //             icon: const Icon(Icons.flash_on),
  //             color: Colors.blue,
  //             onPressed: controller != null ? onFlashModeButtonPressed : null,
  //           ),
  //           // The exposure and focus mode are currently not supported on the web.
  //           ...!kIsWeb
  //               ? <Widget>[
  //                   IconButton(
  //                     icon: const Icon(Icons.exposure),
  //                     color: Colors.blue,
  //                     onPressed: controller != null
  //                         ? onExposureModeButtonPressed
  //                         : null,
  //                   ),
  //                   IconButton(
  //                     icon: const Icon(Icons.filter_center_focus),
  //                     color: Colors.blue,
  //                     onPressed:
  //                         controller != null ? onFocusModeButtonPressed : null,
  //                   )
  //                 ]
  //               : <Widget>[],
  //           IconButton(
  //             icon: Icon(enableAudio ? Icons.volume_up : Icons.volume_mute),
  //             color: Colors.blue,
  //             onPressed: controller != null ? onAudioModeButtonPressed : null,
  //           ),
  //           IconButton(
  //             icon: Icon(controller?.value.isCaptureOrientationLocked ?? false
  //                 ? Icons.screen_lock_rotation
  //                 : Icons.screen_rotation),
  //             color: Colors.blue,
  //             onPressed: controller != null
  //                 ? onCaptureOrientationLockButtonPressed
  //                 : null,
  //           ),
  //         ],
  //       ),
  //       _flashModeControlRowWidget(),
  //       _exposureModeControlRowWidget(),
  //       _focusModeControlRowWidget(),
  //     ],
  //   );
  // }

  // Widget _flashModeControlRowWidget() {
  //   return SizeTransition(
  //     sizeFactor: _flashModeControlRowAnimation,
  //     child: ClipRect(
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: <Widget>[
  //           IconButton(
  //             icon: const Icon(Icons.flash_off),
  //             color: controller?.value.flashMode == FlashMode.off
  //                 ? Colors.orange
  //                 : Colors.blue,
  //             onPressed: controller != null
  //                 ? () => onSetFlashModeButtonPressed(FlashMode.off)
  //                 : null,
  //           ),
  //           IconButton(
  //             icon: const Icon(Icons.flash_auto),
  //             color: controller?.value.flashMode == FlashMode.auto
  //                 ? Colors.orange
  //                 : Colors.blue,
  //             onPressed: controller != null
  //                 ? () => onSetFlashModeButtonPressed(FlashMode.auto)
  //                 : null,
  //           ),
  //           IconButton(
  //             icon: const Icon(Icons.flash_on),
  //             color: controller?.value.flashMode == FlashMode.always
  //                 ? Colors.orange
  //                 : Colors.blue,
  //             onPressed: controller != null
  //                 ? () => onSetFlashModeButtonPressed(FlashMode.always)
  //                 : null,
  //           ),
  //           IconButton(
  //             icon: const Icon(Icons.highlight),
  //             color: controller?.value.flashMode == FlashMode.torch
  //                 ? Colors.orange
  //                 : Colors.blue,
  //             onPressed: controller != null
  //                 ? () => onSetFlashModeButtonPressed(FlashMode.torch)
  //                 : null,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _exposureModeControlRowWidget() {
  //   final ButtonStyle styleAuto = TextButton.styleFrom(
  //     foregroundColor: controller?.value.exposureMode == ExposureMode.auto
  //         ? Colors.orange
  //         : Colors.blue,
  //   );
  //   final ButtonStyle styleLocked = TextButton.styleFrom(
  //     foregroundColor: controller?.value.exposureMode == ExposureMode.locked
  //         ? Colors.orange
  //         : Colors.blue,
  //   );

  //   return SizeTransition(
  //     sizeFactor: _exposureModeControlRowAnimation,
  //     child: ClipRect(
  //       child: ColoredBox(
  //         color: Colors.grey.shade50,
  //         child: Column(
  //           children: <Widget>[
  //             const Center(
  //               child: Text('Exposure Mode'),
  //             ),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: <Widget>[
  //                 TextButton(
  //                   style: styleAuto,
  //                   onPressed: controller != null
  //                       ? () =>
  //                           onSetExposureModeButtonPressed(ExposureMode.auto)
  //                       : null,
  //                   onLongPress: () {
  //                     if (controller != null) {
  //                       controller!.setExposurePoint(null);
  //                       showInSnackBar('Resetting exposure point');
  //                     }
  //                   },
  //                   child: const Text('AUTO'),
  //                 ),
  //                 TextButton(
  //                   style: styleLocked,
  //                   onPressed: controller != null
  //                       ? () =>
  //                           onSetExposureModeButtonPressed(ExposureMode.locked)
  //                       : null,
  //                   child: const Text('LOCKED'),
  //                 ),
  //                 TextButton(
  //                   style: styleLocked,
  //                   onPressed: controller != null
  //                       ? () => controller!.setExposureOffset(0.0)
  //                       : null,
  //                   child: const Text('RESET OFFSET'),
  //                 ),
  //               ],
  //             ),
  //             const Center(
  //               child: Text('Exposure Offset'),
  //             ),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: <Widget>[
  //                 Text(_minAvailableExposureOffset.toString()),
  //                 Slider(
  //                   value: _currentExposureOffset,
  //                   min: _minAvailableExposureOffset,
  //                   max: _maxAvailableExposureOffset,
  //                   label: _currentExposureOffset.toString(),
  //                   onChanged: _minAvailableExposureOffset ==
  //                           _maxAvailableExposureOffset
  //                       ? null
  //                       : setExposureOffset,
  //                 ),
  //                 Text(_maxAvailableExposureOffset.toString()),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _focusModeControlRowWidget() {
  //   final ButtonStyle styleAuto = TextButton.styleFrom(
  //     foregroundColor: controller?.value.focusMode == FocusMode.auto
  //         ? Colors.orange
  //         : Colors.blue,
  //   );
  //   final ButtonStyle styleLocked = TextButton.styleFrom(
  //     foregroundColor: controller?.value.focusMode == FocusMode.locked
  //         ? Colors.orange
  //         : Colors.blue,
  //   );

  //   return SizeTransition(
  //     sizeFactor: _focusModeControlRowAnimation,
  //     child: ClipRect(
  //       child: ColoredBox(
  //         color: Colors.grey.shade50,
  //         child: Column(
  //           children: <Widget>[
  //             const Center(
  //               child: Text('Focus Mode'),
  //             ),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: <Widget>[
  //                 TextButton(
  //                   style: styleAuto,
  //                   onPressed: controller != null
  //                       ? () => onSetFocusModeButtonPressed(FocusMode.auto)
  //                       : null,
  //                   onLongPress: () {
  //                     if (controller != null) {
  //                       controller!.setFocusPoint(null);
  //                     }
  //                     showInSnackBar('Resetting focus point');
  //                   },
  //                   child: const Text('AUTO'),
  //                 ),
  //                 TextButton(
  //                   style: styleLocked,
  //                   onPressed: controller != null
  //                       ? () => onSetFocusModeButtonPressed(FocusMode.locked)
  //                       : null,
  //                   child: const Text('LOCKED'),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // /// Display the control bar with buttons to take pictures and record videos.
  // Widget _captureControlRowWidget() {
  //   final CameraController? cameraController = controller;

  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: <Widget>[
  //       IconButton(
  //         icon: const Icon(Icons.camera_alt),
  //         color: Colors.blue,
  //         onPressed: cameraController != null &&
  //                 cameraController.value.isInitialized &&
  //                 !cameraController.value.isRecordingVideo
  //             ? onTakePictureButtonPressed
  //             : null,
  //       ),
  //       IconButton(
  //         icon: const Icon(Icons.videocam),
  //         color: Colors.blue,
  //         onPressed: cameraController != null &&
  //                 cameraController.value.isInitialized &&
  //                 !cameraController.value.isRecordingVideo
  //             ? onVideoRecordButtonPressed
  //             : null,
  //       ),
  //       IconButton(
  //         icon: cameraController != null &&
  //                 cameraController.value.isRecordingPaused
  //             ? const Icon(Icons.play_arrow)
  //             : const Icon(Icons.pause),
  //         color: Colors.blue,
  //         onPressed: cameraController != null &&
  //                 cameraController.value.isInitialized &&
  //                 cameraController.value.isRecordingVideo
  //             ? (cameraController.value.isRecordingPaused)
  //                 ? onResumeButtonPressed
  //                 : onPauseButtonPressed
  //             : null,
  //       ),
  //       IconButton(
  //         icon: const Icon(Icons.stop),
  //         color: Colors.red,
  //         onPressed: cameraController != null &&
  //                 cameraController.value.isInitialized &&
  //                 cameraController.value.isRecordingVideo
  //             ? onStopButtonPressed
  //             : null,
  //       ),
  //       IconButton(
  //         icon: const Icon(Icons.pause_presentation),
  //         color:
  //             cameraController != null && cameraController.value.isPreviewPaused
  //                 ? Colors.red
  //                 : Colors.blue,
  //         onPressed:
  //             cameraController == null ? null : onPausePreviewButtonPressed,
  //       ),
  //     ],
  //   );
  // }

  // /// Display a row of toggle to select the camera (or a message if no camera is available).
  // Widget _cameraTogglesRowWidget() {
  //   final List<Widget> toggles = <Widget>[];

  //   void onChanged(CameraDescription? description) {
  //     if (description == null) {
  //       return;
  //     }

  //     onNewCameraSelected(description);
  //   }

  //   if (_cameras.isEmpty) {
  //     SchedulerBinding.instance.addPostFrameCallback((_) async {
  //       showInSnackBar('No camera found.');
  //     });
  //     return const Text('None');
  //   } else {
  //     for (final CameraDescription cameraDescription in _cameras) {
  //       toggles.add(
  //         SizedBox(
  //           width: 90.0,
  //           child: RadioListTile<CameraDescription>(
  //             title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
  //             groupValue: controller?.description,
  //             value: cameraDescription,
  //             onChanged: onChanged,
  //           ),
  //         ),
  //       );
  //     }
  //   }

  //   return Row(children: toggles);
  // }

  // String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  // void showInSnackBar(String message) {
  //   ScaffoldMessenger.of(context)
  //       .showSnackBar(SnackBar(content: Text(message)));
  // }

  // void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
  //   if (controller == null) {
  //     return;
  //   }

  //   final CameraController cameraController = controller!;

  //   final Offset offset = Offset(
  //     details.localPosition.dx / constraints.maxWidth,
  //     details.localPosition.dy / constraints.maxHeight,
  //   );
  //   cameraController.setExposurePoint(offset);
  //   cameraController.setFocusPoint(offset);
  // }

  // Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
  //   if (controller != null) {
  //     return controller!.setDescription(cameraDescription);
  //   } else {
  //     return _initializeCameraController(cameraDescription);
  //   }
  // }

  // Future<void> _initializeCameraController(
  //     CameraDescription cameraDescription) async {
  //   controller = CameraController(
  //     cameraDescription,
  //     ResolutionPreset.medium,
  //     enableAudio: enableAudio,
  //     imageFormatGroup: ImageFormatGroup.jpeg,
  //   );

  //   // If the controller is updated then update the UI.
  //   controller?.addListener(() {
  //     if (mounted) {
  //       setState(() {});
  //     }
  //     if (controller!.value.hasError) {
  //       showInSnackBar('Camera error ${controller!.value.errorDescription}');
  //     }
  //   });

  //   try {
  //     await controller?.initialize();
  //     await Future.wait(<Future<Object?>>[
  //       // The exposure mode is currently not supported on the web.
  //       ...!kIsWeb
  //           ? <Future<Object?>>[
  //               controller!.getMinExposureOffset().then(
  //                   (double value) => _minAvailableExposureOffset = value),
  //               controller!
  //                   .getMaxExposureOffset()
  //                   .then((double value) => _maxAvailableExposureOffset = value)
  //             ]
  //           : <Future<Object?>>[],
  //       controller!
  //           .getMaxZoomLevel()
  //           .then((double value) => _maxAvailableZoom = value),
  //       controller!
  //           .getMinZoomLevel()
  //           .then((double value) => _minAvailableZoom = value),
  //     ]);
  //   } on CameraException catch (e) {
  //     switch (e.code) {
  //       case 'CameraAccessDenied':
  //         showInSnackBar('You have denied camera access.');
  //       case 'CameraAccessDeniedWithoutPrompt':
  //         // iOS only
  //         showInSnackBar('Please go to Settings app to enable camera access.');
  //       case 'CameraAccessRestricted':
  //         // iOS only
  //         showInSnackBar('Camera access is restricted.');
  //       case 'AudioAccessDenied':
  //         showInSnackBar('You have denied audio access.');
  //       case 'AudioAccessDeniedWithoutPrompt':
  //         // iOS only
  //         showInSnackBar('Please go to Settings app to enable audio access.');
  //       case 'AudioAccessRestricted':
  //         // iOS only
  //         showInSnackBar('Audio access is restricted.');
  //       default:
  //         _showCameraException(e);
  //         break;
  //     }
  //   }

  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  // void onTakePictureButtonPressed() {
  //   takePicture().then((XFile? file) {
  //     if (mounted) {
  //       setState(() {
  //         imageFile = file;
  //         videoController?.dispose();
  //         videoController = null;
  //       });
  //       if (file != null) {
  //         showInSnackBar('Picture saved to ${file.path}');
  //       }
  //     }
  //   });
  // }

  // void onFlashModeButtonPressed() {
  //   if (_flashModeControlRowAnimationController.value == 1) {
  //     _flashModeControlRowAnimationController.reverse();
  //   } else {
  //     _flashModeControlRowAnimationController.forward();
  //     _exposureModeControlRowAnimationController.reverse();
  //     _focusModeControlRowAnimationController.reverse();
  //   }
  // }

  // void onExposureModeButtonPressed() {
  //   if (_exposureModeControlRowAnimationController.value == 1) {
  //     _exposureModeControlRowAnimationController.reverse();
  //   } else {
  //     _exposureModeControlRowAnimationController.forward();
  //     _flashModeControlRowAnimationController.reverse();
  //     _focusModeControlRowAnimationController.reverse();
  //   }
  // }

  // void onFocusModeButtonPressed() {
  //   if (_focusModeControlRowAnimationController.value == 1) {
  //     _focusModeControlRowAnimationController.reverse();
  //   } else {
  //     _focusModeControlRowAnimationController.forward();
  //     _flashModeControlRowAnimationController.reverse();
  //     _exposureModeControlRowAnimationController.reverse();
  //   }
  // }

  // void onAudioModeButtonPressed() {
  //   enableAudio = !enableAudio;
  //   if (controller != null) {
  //     onNewCameraSelected(controller!.description);
  //   }
  // }

  // Future<void> onCaptureOrientationLockButtonPressed() async {
  //   try {
  //     if (controller != null) {
  //       final CameraController cameraController = controller!;
  //       if (cameraController.value.isCaptureOrientationLocked) {
  //         await cameraController.unlockCaptureOrientation();
  //         showInSnackBar('Capture orientation unlocked');
  //       } else {
  //         await cameraController.lockCaptureOrientation();
  //         showInSnackBar(
  //             'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
  //       }
  //     }
  //   } on CameraException catch (e) {
  //     _showCameraException(e);
  //   }
  // }

  // void onSetFlashModeButtonPressed(FlashMode mode) {
  //   setFlashMode(mode).then((_) {
  //     if (mounted) {
  //       setState(() {});
  //     }
  //     showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
  //   });
  // }

  // void onSetExposureModeButtonPressed(ExposureMode mode) {
  //   setExposureMode(mode).then((_) {
  //     if (mounted) {
  //       setState(() {});
  //     }
  //     showInSnackBar('Exposure mode set to ${mode.toString().split('.').last}');
  //   });
  // }

  // void onSetFocusModeButtonPressed(FocusMode mode) {
  //   setFocusMode(mode).then((_) {
  //     if (mounted) {
  //       setState(() {});
  //     }
  //     showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
  //   });
  // }

  // void onVideoRecordButtonPressed() {
  //   startVideoRecording().then((_) {
  //     if (mounted) {
  //       setState(() {});
  //     }
  //   });
  // }

  // void onStopButtonPressed() {
  //   stopVideoRecording().then((XFile? file) {
  //     if (mounted) {
  //       setState(() {});
  //     }
  //     if (file != null) {
  //       showInSnackBar('Video recorded to ${file.path}');
  //       videoFile = file;
  //       _startVideoPlayer();
  //     }
  //   });
  // }

  // Future<void> onPausePreviewButtonPressed() async {
  //   final CameraController? cameraController = controller;

  //   if (cameraController == null || !cameraController.value.isInitialized) {
  //     showInSnackBar('Error: select a camera first.');
  //     return;
  //   }

  //   if (cameraController.value.isPreviewPaused) {
  //     await cameraController.resumePreview();
  //   } else {
  //     await cameraController.pausePreview();
  //   }

  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  // void onPauseButtonPressed() {
  //   pauseVideoRecording().then((_) {
  //     if (mounted) {
  //       setState(() {});
  //     }
  //     showInSnackBar('Video recording paused');
  //   });
  // }

  // void onResumeButtonPressed() {
  //   resumeVideoRecording().then((_) {
  //     if (mounted) {
  //       setState(() {});
  //     }
  //     showInSnackBar('Video recording resumed');
  //   });
  // }

  // Future<void> startVideoRecording() async {
  //   final CameraController? cameraController = controller;

  //   if (cameraController == null || !cameraController.value.isInitialized) {
  //     showInSnackBar('Error: select a camera first.');
  //     return;
  //   }

  //   if (cameraController.value.isRecordingVideo) {
  //     // A recording is already started, do nothing.
  //     return;
  //   }

  //   try {
  //     await cameraController.startVideoRecording();
  //   } on CameraException catch (e) {
  //     _showCameraException(e);
  //     return;
  //   }
  // }

  // Future<XFile?> stopVideoRecording() async {
  //   final CameraController? cameraController = controller;

  //   if (cameraController == null || !cameraController.value.isRecordingVideo) {
  //     return null;
  //   }

  //   try {
  //     return cameraController.stopVideoRecording();
  //   } on CameraException catch (e) {
  //     _showCameraException(e);
  //     return null;
  //   }
  // }

  // Future<void> pauseVideoRecording() async {
  //   final CameraController? cameraController = controller;

  //   if (cameraController == null || !cameraController.value.isRecordingVideo) {
  //     return;
  //   }

  //   try {
  //     await cameraController.pauseVideoRecording();
  //   } on CameraException catch (e) {
  //     _showCameraException(e);
  //     rethrow;
  //   }
  // }

  // Future<void> resumeVideoRecording() async {
  //   final CameraController? cameraController = controller;

  //   if (cameraController == null || !cameraController.value.isRecordingVideo) {
  //     return;
  //   }

  //   try {
  //     await cameraController.resumeVideoRecording();
  //   } on CameraException catch (e) {
  //     _showCameraException(e);
  //     rethrow;
  //   }
  // }

  // Future<void> setFlashMode(FlashMode mode) async {
  //   if (controller == null) {
  //     return;
  //   }

  //   try {
  //     await controller!.setFlashMode(mode);
  //   } on CameraException catch (e) {
  //     _showCameraException(e);
  //     rethrow;
  //   }
  // }

  // Future<void> setExposureMode(ExposureMode mode) async {
  //   if (controller == null) {
  //     return;
  //   }

  //   try {
  //     await controller!.setExposureMode(mode);
  //   } on CameraException catch (e) {
  //     _showCameraException(e);
  //     rethrow;
  //   }
  // }

  // Future<void> setExposureOffset(double offset) async {
  //   if (controller == null) {
  //     return;
  //   }

  //   setState(() {
  //     _currentExposureOffset = offset;
  //   });
  //   try {
  //     offset = await controller!.setExposureOffset(offset);
  //   } on CameraException catch (e) {
  //     _showCameraException(e);
  //     rethrow;
  //   }
  // }

  // Future<void> setFocusMode(FocusMode mode) async {
  //   if (controller == null) {
  //     return;
  //   }

  //   try {
  //     await controller!.setFocusMode(mode);
  //   } on CameraException catch (e) {
  //     _showCameraException(e);
  //     rethrow;
  //   }
  // }

  // Future<void> _startVideoPlayer() async {
  //   if (videoFile == null) {
  //     return;
  //   }

  //   final VideoPlayerController vController = kIsWeb
  //       ? VideoPlayerController.networkUrl(Uri.parse(videoFile!.path))
  //       : VideoPlayerController.file(File(videoFile!.path));

  //   videoPlayerListener = () {
  //     if (videoController != null) {
  //       // Refreshing the state to update video player with the correct ratio.
  //       if (mounted) {
  //         setState(() {});
  //       }
  //       videoController!.removeListener(videoPlayerListener!);
  //     }
  //   };
  //   vController.addListener(videoPlayerListener!);
  //   await vController.setLooping(true);
  //   await vController.initialize();
  //   await videoController?.dispose();
  //   if (mounted) {
  //     setState(() {
  //       imageFile = null;
  //       videoController = vController;
  //     });
  //   }
  //   await vController.play();
  // }

  // Future<XFile?> takePicture() async {
  //   final CameraController? cameraController = controller;
  //   if (cameraController == null || !cameraController.value.isInitialized) {
  //     showInSnackBar('Error: select a camera first.');
  //     return null;
  //   }

  //   if (cameraController.value.isTakingPicture) {
  //     // A capture is already pending, do nothing.
  //     return null;
  //   }

  //   try {
  //     final XFile file = await cameraController.takePicture();
  //     return file;
  //   } on CameraException catch (e) {
  //     _showCameraException(e);
  //     return null;
  //   }
  // }

  // void _showCameraException(CameraException e) {
  //   _logError(e.code, e.description);
  //   showInSnackBar('Error: ${e.code}\n${e.description}');
  // }
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
  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();
  } on CameraException catch (e) {
    _logError(e.code, e.description);
  }
  runApp(const CameraApp());
}
