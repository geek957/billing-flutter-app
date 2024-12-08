import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'Product.dart';
import 'CustomAddBar.dart';
import 'DisplayPictureScreen.dart';
import 'package:http/http.dart' as http;
import 'Config.dart';
import 'dart:convert';

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
  final ImagePicker _picker = ImagePicker();

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
    // Add a delay of 1 second
    // await Future.delayed(const Duration(seconds: 1));

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse('${Config.apiUrl}/search'));
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    // Send the request
    var response = await request.send();
    Product product = Product(
      id: (Random().nextInt(10) + 100).toString(),
      imagePath: imagePath,
      name: "test",
      quantity: 1,
      cost: Random().nextInt(30),
    );
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseBody);
      product = Product(
        id: jsonResponse["id"],
        imagePath: imagePath,
        quantity: 1,
        name: jsonResponse["nickname"],
        cost: jsonResponse["price"]
      );
      print('Ping successful: $responseBody');
    } else {
      print('Ping failed with status: ${response.statusCode}');
    }

    // Simulate image upload and product creation
    widget.onImageCaptured(product);
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _uploadImage(pickedFile.path);
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            camera: widget.camera,
            products: widget.products,
            onHomePressed: widget.onHomePressed,
          ),
        ),
      );
    }
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
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
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _pickImageFromGallery,
            tooltip: 'Pick Image from Gallery',
            child: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}
