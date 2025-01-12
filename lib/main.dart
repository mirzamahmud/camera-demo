import 'dart:async';
import 'package:camera_demo/camera_demo.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CameraDemo());
}
