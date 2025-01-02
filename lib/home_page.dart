import 'package:billing/admin_home_page.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'custom_app_bar.dart';
import 'camera_screen.dart';
import 'product.dart';

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
                    backgroundColor: const Color.fromARGB(255, 108, 206, 111), // Set the background color to green
                    minimumSize: Size(80, 40), // Set the minimum size of the button
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Adjust padding
                    textStyle: TextStyle(fontSize: 20), // Increase the font size
                  ),
                  child: const Text('Begin'),
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
          Positioned(
            bottom: 16,
            left: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AdminHomePage(
                          camera: widget.camera
                        ),
                      ),
                    );
              },
              child: const Text('Admin'),
            ),
          ),
        ],
      ),
    );
  }
}
