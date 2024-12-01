import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'Product.dart';
import 'CustomAddBar.dart';
import 'DisplayPictureScreen.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final Function(Product) onImageCaptured;
  final List<Product> products;
  final VoidCallback onHomePressed;

  const CameraScreen({super.key, required this.camera, required this.onImageCaptured, required this.products, required this.onHomePressed});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _uploadImage(String imagePath) async {
    await Future.delayed(Duration(microseconds: Random().nextInt(1000) + 10000));
    widget.onImageCaptured(Product(id: "{Random().nextInt(10) + 100}",imagePath: imagePath, quantity: 1, cost: Random().nextInt(30)));
    return;
    // final request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:3000/upload'));
    // request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    // final response = await request.send();

    // if (response.statusCode == 200) {
    //   final responseBody = await response.stream.bytesToString();
    //   final responseData = json.decode(responseBody);
    //   final product = Product(
    //     id: responseData['id'],
    //     imagePath: imagePath,
    //     quantity: 1,
    //     cost: responseData['cost'],
    //   );
    //   widget.onImageCaptured(product);
    // } else {
    //   print("Failed to upload image");
    //   widget.onImageCaptured(Product(id: "{Random().nextInt(10) + 100}",imagePath: imagePath, quantity: 1, cost: Random().nextInt(30)));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Capture',
        onHomePressed: widget.onHomePressed,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            if (!mounted) return;
            
            await _uploadImage(image.path);
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  camera: widget.camera,
                  products: [...widget.products],
                  onHomePressed: widget.onHomePressed,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        tooltip: 'Capture',
        child: const Icon(Icons.camera),
      ),
    );
  }
}
