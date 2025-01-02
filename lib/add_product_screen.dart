import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'config.dart';
import 'admin_home_page.dart';
import 'add_product_camera_screen.dart';
import 'video_player_screen.dart';

class AddProductScreen extends StatefulWidget {
  final CameraDescription camera;

  const AddProductScreen({super.key, required this.camera});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  File? _videoFile;
  VideoPlayerController? _videoPlayerController;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideoFromGallery() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
        _videoPlayerController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {});
            _videoPlayerController!.play();
          });
      });
    }
  }

  Future<void> _captureVideo() async {
    final videoFile = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductCameraScreen(camera: widget.camera),
      ),
    );
    if (videoFile != null) {
      setState(() {
        _videoFile = videoFile;
        _videoPlayerController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {});
            _videoPlayerController!.play();
          });
      });
    }
  }

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      if (_videoFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please add a video')));
        return;
      }

      final request = http.MultipartRequest('POST', Uri.parse('${Config.apiUrl}/addProduct?merchantId=${Config.merchantId}'));
      request.fields['name'] = _nameController.text;
      request.fields['price'] = _priceController.text;
      request.files.add(await http.MultipartFile.fromPath('video', _videoFile!.path));
      request.headers.addEntries([
        MapEntry('Authorization', Config.authString),
      ]);

      final response = await request.send();
      // final response = {
      //   "statusCode": 200
      // };
      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdminHomePage(camera: widget.camera),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding product')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  final regex = RegExp(r'^[a-zA-Z0-9 .]+$');
                  if (!regex.hasMatch(value)) {
                    return 'Invalid characters in name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  final price = int.tryParse(value);
                  if (price == null || price < 1 || price > 10000) {
                    return 'Price must be between 1 and 10000';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),
              Text('Video', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              if (_videoFile == null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _captureVideo,
                      child: Text('Capture'),
                    ),
                    ElevatedButton(
                      onPressed: _pickVideoFromGallery,
                      child: Text('Gallery'),
                    ),
                  ],
                ),
              if (_videoFile != null) ...[
                SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      child: VideoPlayer(_videoPlayerController!),
                    ),
                    IconButton(
                      icon: Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(videoFile: _videoFile!),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red, size: 40,),
                  onPressed: () {
                    setState(() {
                      _videoFile = null;
                      _videoPlayerController?.dispose();
                      _videoPlayerController = null;
                    });
                  },
                ),
              ],
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 143, 183, 99), // Set the background color to light green
                ),
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}