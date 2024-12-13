import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'CustomAddBar.dart';
import 'CameraScreen.dart';
import 'Product.dart';

class HomePage extends StatefulWidget {
  final CameraDescription camera;

  const HomePage({super.key, required this.camera});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];

  void addProduct(Product product) {
    setState(() {
      products.add(product);
    });
  }

  void resetProducts() {
    setState(() {
      products = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Billing',
        onHomePressed: resetProducts,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(
                          camera: widget.camera,
                          onImageCaptured: addProduct,
                          products: products,
                          onHomePressed: resetProducts,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Set the background color to green
                  ),
                  child: const Text('Start'),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
          ),
        ],
      ),
    );
  }
}
