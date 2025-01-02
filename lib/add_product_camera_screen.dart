import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';

class AddProductCameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const AddProductCameraScreen({super.key, required this.camera});

  @override
  _AddProductCameraScreenState createState() => _AddProductCameraScreenState();
}

class _AddProductCameraScreenState extends State<AddProductCameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;
  Timer? _timer;
  int _recordingTime = 0;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startVideoRecording() async {
    if (!_isRecording) {
      try {
        await _initializeControllerFuture;
        await _controller.startVideoRecording();
        setState(() {
          _isRecording = true;
          _recordingTime = 0;
        });
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            _recordingTime++;
          });
          if (_recordingTime >= 10) {
            _stopVideoRecording();
          }
        });
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_isRecording) {
      try {
        final videoFile = await _controller.stopVideoRecording();
        _timer?.cancel();
        setState(() {
          _isRecording = false;
        });
        Navigator.pop(context, File(videoFile.path));
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capture'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _isRecording ? _recordingTime / 10 : 0,
                            strokeWidth: 30.0, // Increase the stroke width for a bigger filling
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                          GestureDetector(
                            onTap: _isRecording ? _stopVideoRecording : _startVideoRecording,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isRecording ? Colors.red : Colors.green,
                                border: Border.all(color: Colors.yellow, width: 2),
                              ),
                              child: Icon(
                                _isRecording ? Icons.stop : Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}