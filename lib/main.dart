import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'home_page.dart';
import 'settings_screen.dart';
import 'http_overrides.dart';
import 'config.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  CameraDescription? firstCamera;
  if (cameras.isNotEmpty) {
    firstCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );
  }
  await Config.initialize();
  runApp(MyApp(camera: firstCamera ?? CameraDescription(name: 'Default', lensDirection: CameraLensDirection.back, sensorOrientation: 0)));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(camera: camera),
      routes: {
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
