import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'Product.dart';
import 'CameraScreen.dart';
import 'CustomAddBar.dart';

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
      body: Center(
        child: ElevatedButton(
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
          child: const Text('Start'),
        ),
      ),
    );
  }
}
