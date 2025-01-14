import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_demo/screens/camera/controller/camera_controller.dart';
import 'package:camera_demo/screens/video_play_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CameraScreen extends GetView<MyCameraController> {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            Obx(() {
              return Column(
                children: [
                  Expanded(
                      child: CameraPreview(controller.cameraController.value!)),
                ],
              );
            }),
            Positioned(
              right: 16,
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  children: [
                    controller.isShowSpeed.value
                        ? Row(
                            children: [
                              Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                    vertical: 2, horizontal: 2),
                                decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  children: List.generate(
                                      controller.videoSpeed.length, (index) {
                                    final speed = controller.videoSpeed[index];
                                    return TextButton(
                                        onPressed: () {
                                          controller.selectedVideoSpeed.value =
                                              speed;
                                          controller.isShowSpeed.value = false;
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
                              controller.switchCamera();
                            },
                            icon: const Icon(Icons.recycling,
                                size: 20, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          IconButton(
                            onPressed: () {
                              controller.toggleFlash();
                            },
                            icon: controller.isFlashOn.value
                                ? const Icon(Icons.flash_on_outlined,
                                    size: 20, color: Colors.amber)
                                : const Icon(Icons.flash_off_outlined,
                                    size: 20, color: Colors.white),
                          ),
                          controller.isPhoto.value
                              ? const SizedBox()
                              : const SizedBox(height: 8),
                          controller.isPhoto.value
                              ? const SizedBox()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        controller.isShowSpeed.value =
                                            !controller.isShowSpeed.value;
                                      },
                                      icon:
                                          controller.selectedVideoSpeed.value !=
                                                  -1
                                              ? const Icon(Icons.speed_outlined,
                                                  size: 20, color: Colors.teal)
                                              : const Icon(Icons.speed_outlined,
                                                  size: 20,
                                                  color: Colors.white),
                                    ),
                                    controller.selectedVideoSpeed.value == -1
                                        ? const SizedBox()
                                        : const SizedBox(height: 0),
                                    controller.selectedVideoSpeed.value == -1
                                        ? const SizedBox()
                                        : Text(
                                            '${controller.selectedVideoSpeed.value}x',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.teal,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400),
                                          )
                                  ],
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
                          controller.isSixtySec.value = true;

                          if (controller.isSixtySec.value) {
                            controller.isFifteenSec.value = false;
                            controller.isPhoto.value = false;
                          }
                        },
                        child: Text(
                          '60 SEC',
                          textAlign: TextAlign.center,
                          style: controller.isSixtySec.value
                              ? const TextStyle(
                                  color: Colors.amber, fontSize: 16)
                              : const TextStyle(
                                  color: Colors.white, fontSize: 16),
                        )),
                    TextButton(
                        onPressed: () {
                          controller.isFifteenSec.value = true;

                          if (controller.isFifteenSec.value) {
                            controller.isSixtySec.value = false;
                            controller.isPhoto.value = false;
                          }
                        },
                        child: Text(
                          '15 SEC',
                          textAlign: TextAlign.center,
                          style: controller.isFifteenSec.value
                              ? const TextStyle(
                                  color: Colors.amber, fontSize: 16)
                              : const TextStyle(
                                  color: Colors.white, fontSize: 16),
                        )),
                    TextButton(
                        onPressed: () {
                          controller.isPhoto.value = true;

                          if (controller.isPhoto.value) {
                            controller.isSixtySec.value = false;
                            controller.isFifteenSec.value = false;
                          }
                        },
                        child: Text(
                          'PHOTO',
                          textAlign: TextAlign.center,
                          style: controller.isPhoto.value
                              ? const TextStyle(
                                  color: Colors.amber, fontSize: 16)
                              : const TextStyle(
                                  color: Colors.white, fontSize: 16),
                        ))
                  ],
                ),
                const SizedBox(height: 20),
                // ================= capture button ============================
                controller.isPhoto.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Spacer(flex: 1),
                          Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 32),
                                    child: GestureDetector(
                                      onTap: () {
                                        controller.capturePhoto();
                                      },
                                      child: Container(
                                        height: 64,
                                        width: 64,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 4)),
                                      ),
                                    ),
                                  ),
                                  controller.imageFile.value == null
                                      ? const SizedBox()
                                      : const SizedBox(width: 32),
                                  controller.imageFile.value == null
                                      ? const SizedBox()
                                      : Container(
                                          height: 60,
                                          width: 60,
                                          margin:
                                              const EdgeInsetsDirectional.only(
                                                  end: 16),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              image: DecorationImage(
                                                  image: FileImage(File(
                                                      controller.imageFile
                                                          .value!.path)),
                                                  fit: BoxFit.cover)),
                                        )
                                ],
                              ))
                        ],
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
                                percent: controller.progress.value,
                                progressColor: Colors.red,
                                center: GestureDetector(
                                  onTap: () async {
                                    if (controller.isFifteenSec.value) {
                                      await controller.startVideoRecording();
                                    } else {
                                      await controller
                                          .startSixtySecVideoRecording();
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
                          controller.videoFile.value == null
                              ? const SizedBox()
                              : IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => VideoPlayScreen(
                                                videoSpeed: controller
                                                    .selectedVideoSpeed.value,
                                                videoSrc: controller.videoFile
                                                        .value?.path ??
                                                    '')));
                                  },
                                  icon: Container(
                                    height: 24,
                                    width: 24,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                        color: Colors.teal,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.done,
                                        size: 16, color: Colors.white),
                                  ))
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
