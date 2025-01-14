import 'package:camera_demo/routes/app_routes.dart';
import 'package:camera_demo/screens/camera/binding/camera_binding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CameraDemo extends StatelessWidget {
  const CameraDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: CameraBinding(),
      initialRoute: AppRoutes.cameraScreen,
      getPages: AppRoutes.routes,
    );
  }
}
