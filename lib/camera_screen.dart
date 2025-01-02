import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'product.dart';
import 'custom_app_bar.dart';
import 'display_picture_screen.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
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
  bool _isLoading = false;

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
    setState(() {
      _isLoading = true;
    });

    final url = Config.apiUrl;
    final merchantId = Config.merchantId == 'test' ? '1' : Config.merchantId;
    final request = http.MultipartRequest('POST', Uri.parse('$url/search?merchantId=$merchantId'));
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    request.headers.addEntries([
      MapEntry('Authorization', Config.authString),
    ]);
    final response = await request.send();
    Product product = Product(
      id: (Random().nextInt(10) + 100).toString(),
      imagePath: imagePath,
      name: "test",
      quantity: 1,
      price: Random().nextInt(30),
    );
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);
      product = Product(
        id: jsonResponse["id"],
        imagePath: imagePath,
        quantity: 1,
        name: jsonResponse["name"],
        price: jsonResponse["price"]
      );
      print('Ping successful: $responseBody');
    } else {
      print('Ping failed with status: ${response.statusCode}');
    }
    setState(() {
      _isLoading = false;
    });

    // Simulate image upload and product creation
    widget.onImageCaptured(product);
    _showFeedbackPopup(imagePath, product);
  }

  void _showFeedbackPopup(String imagePath, Product product) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Feedback',
                style: TextStyle(fontSize: 18), // Set the desired font size
              ),
              content: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        width: 150, // Set the desired width
                        height: 150, // Set the desired height
                        child: Image.file(File(product.imagePath)),
                      ),
                      Text('Product: ${product.name}'),
                      Text('Description: ${product.price}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.thumb_up, color: Colors.green),
                            iconSize: 40, // Increase the size of the icon
                            onPressed: () => _sendFeedback(imagePath, product, 'like', setState),
                          ),
                          IconButton(
                            icon: Icon(Icons.thumb_down, color: Colors.red),
                            iconSize: 40, // Increase the size of the icon
                            onPressed: () => _sendFeedback(imagePath, product, 'unlike', setState),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToNextPage(),
                        child: Text('Next'),
                      ),
                    ],
                  ),
                  if (_isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _sendFeedback(String imagePath, Product product, String status, StateSetter setState) async {
    setState(() {
      _isLoading = true;
    });
    final String correct = status == 'like' ? 'yes' : 'no';
    final String url = '${Config.apiUrl}/feedback?merchantId=${Config.merchantId}&productId=${product.id}&correct=$correct';

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    request.headers.addEntries([
      MapEntry('Authorization', Config.authString),
    ]);

    await request.send();

    if (status == 'unlike') {
      widget.products.removeLast();
    }
    setState(() {
      _isLoading = false;
    });
    _navigateToNextPage();
  }

  void _navigateToNextPage() {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DisplayPictureScreen(
          camera: widget.camera,
          products: [...widget.products],
          onHomePressed: widget.onHomePressed,
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _uploadImage(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Capture',
        onHomePressed: widget.onHomePressed,
      ),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
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
