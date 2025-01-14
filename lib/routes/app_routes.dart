import 'package:camera_demo/screens/camera/binding/camera_binding.dart';
import 'package:camera_demo/screens/camera/camera_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const String cameraScreen = '/camera_screen';
  static const String videoScreen = '/video_screen';

  static List<GetPage> routes = [
    GetPage(
        name: cameraScreen,
        page: () => const CameraScreen(),
        binding: CameraBinding()),
  ];
}
