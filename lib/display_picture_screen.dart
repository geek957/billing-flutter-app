import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'product.dart';
import 'custom_app_bar.dart';
import 'camera_screen.dart';

class DisplayPictureScreen extends StatelessWidget {
  final CameraDescription camera;
  final List<Product> products;
  final Function() onHomePressed;

  const DisplayPictureScreen({super.key, required this.camera, required this.products, required this.onHomePressed});

  @override
  Widget build(BuildContext context) {
    // Calculate total quantity and total price
    int totalQuantity = products.length;
    int totalPrice = products.fold(0, (sum, product) => sum + product.price);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Cart',
        onHomePressed: this.onHomePressed,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                  ),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(totalQuantity.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("${totalPrice} \₹", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...products.map((product) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 8.0, bottom: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 50, // Adjust the height as needed
                              child: Image.file(File(product.imagePath)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                               product.name.length > 16
                                  ? '${product.name.substring(0, 16)}...'
                                  : product.name,
                            ), // Display the product name beside the image
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(product.quantity.toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("${product.price.toString()} \₹"),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(
                      camera: camera,
                      onImageCaptured: (Product product) {
                        products.add(product);
                      },
                      products: products,
                      onHomePressed: this.onHomePressed,
                    ),
                  ),
                );
              },
              child: const Text('Add more'),
            ),
          ],
        ),
      ),
    );
  }
}
