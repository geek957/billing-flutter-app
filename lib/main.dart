import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'HomePage.dart';
import 'SettingsScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.firstWhere(
    (camera) => camera.lensDirection == CameraLensDirection.back,
  );

  runApp(MyApp(camera: firstCamera));
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

