import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyCameraController extends GetxController with WidgetsBindingObserver {
  List<CameraDescription> cameras = <CameraDescription>[];
  Rx<CameraController?> cameraController = Rx(null);
  Rx<XFile?> imageFile = Rx(null);
  Rx<XFile?> videoFile = Rx(null);
  Rx<bool> isShowSpeed = false.obs;
  Rx<bool> isPhoto = false.obs;
  Rx<bool> isFifteenSec = false.obs;
  Rx<bool> isSixtySec = false.obs;
  Rx<bool> isRecording = false.obs;
  Rx<double> progress = 0.0.obs;
  Timer? timer;
  Rx<int> currentCameraIndex = 0.obs;
  Rx<bool> isCameraInitialaized = Rx(false);

  List<double> videoSpeed = [2.0, 1.5, 1, 0.5, 0.25];
  Rx<double> selectedVideoSpeed = Rx(-1);

  Future<void> switchCamera() async {
    currentCameraIndex.value =
        (currentCameraIndex.value + 1) % (cameras.length);
    cameraController.value?.dispose();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    cameraController.value = CameraController(
        cameras[currentCameraIndex.value], ResolutionPreset.high);
    await cameraController.value?.initialize();
    await cameraController.value?.lockCaptureOrientation();
    cameraController.refresh();
    isCameraInitialaized.value = true;
  }

  Future<void> startVideoRecording() async {
    try {
      await cameraController.value?.startVideoRecording();

      isRecording.value = true;
      progress.value = 0.0;

      // Start progress timer for 15 seconds
      timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        progress += 0.1 / 15; // Increment progress
        if (progress >= 1.0) {
          progress.value = 1.0;
          timer.cancel();
        }
      });

      // Stop recording after 15 seconds
      Future.delayed(const Duration(seconds: 15), () async {
        if (isRecording.value) {
          await stopVideoRecording();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> startSixtySecVideoRecording() async {
    try {
      await cameraController.value?.startVideoRecording();

      isRecording.value = true;
      progress.value = 0.0;

      // Start progress timer for 15 seconds
      timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        progress += 0.1 / 60; // Increment progress
        if (progress >= 1.0) {
          progress.value = 1.0;
          timer.cancel();
        }
      });

      // Stop recording after 15 seconds
      Future.delayed(const Duration(seconds: 60), () async {
        if (isRecording.value) {
          await stopVideoRecording();
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> stopVideoRecording() async {
    try {
      videoFile.value = await cameraController.value?.stopVideoRecording();

      isRecording.value = false;
      progress.value = 0.0;
      timer?.cancel();
    } catch (e) {}
  }

  Future<void> capturePhoto() async {
    if (cameraController.value!.value.isInitialized) {
      try {
        final image = await cameraController.value?.takePicture();

        imageFile.value = image;
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Rx<bool> isFlashOn = false.obs;

  Future<void> toggleFlash() async {
    try {
      if (isFlashOn.value) {
        await cameraController.value?.setFlashMode(FlashMode.off);
      } else {
        await cameraController.value?.setFlashMode(FlashMode.torch);
      }

      isFlashOn.value = !isFlashOn.value;
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    isPhoto.value = true;
    WidgetsBinding.instance.addObserver(this);
    initializeCamera();
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
    cameraController.value?.dispose();
    timer?.cancel();
  }
}
