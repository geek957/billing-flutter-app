import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_product_screen.dart';
import 'config.dart';

class AdminHomePage extends StatefulWidget {
  final CameraDescription camera;

  const AdminHomePage({super.key, required this.camera});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final request = http.Request('GET', Uri.parse('${Config.apiUrl}/getProducts?merchantId=${Config.merchantId}'));
    request.headers.addEntries([
      MapEntry('Authorization', Config.authString),
    ]);
    final response = await request.send();
    // final response = http.Response('[]', 200);
    if (response.statusCode == 200) {
      
        final responseBody = await response.stream.bytesToString();
        _products = List<Map<String, dynamic>>.from(json.decode(responseBody));
        // _products = [
        //   {'id': 1, 'name': 'Product 1', 'price': 100},
        //   {'id': 2, 'name': 'Product 2', 'price': 200},
        //   {'id': 3, 'name': 'Product 3', 'price': 300},
        // ];
        _isLoading = false;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching products')));
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteProduct(String id) async {
    final request = http.Request('DELETE', Uri.parse('${Config.apiUrl}/deleteProduct?merchantId=${Config.merchantId}&id=$id'));
    request.headers.addEntries([
      MapEntry('Authorization', Config.authString),
    ]);
    final response = await request.send();
    // final response = await http.delete(Uri.parse('${Config.apiUrl}/deleteProduct?merchantId=$Config.merchantId,id=$id'));
    // final response = http.Response('[]', 200);
    if (response.statusCode == 200) {
      setState(() {
        _products.removeWhere((product) => product['id'] == id);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting product')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final double idColumnWidth = constraints.maxWidth / 8; 
                    final double actionsColumnWidth = constraints.maxWidth / 8; // Reduced width for Actions column
                    final double priceColumnWidth = constraints.maxWidth / 8; 
                    final double nameColumnWidth = constraints.maxWidth/4; // Adjusted to fit within the screen

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          if (_products.isNotEmpty)
                            DataTable(
                              columnSpacing: constraints.maxHeight / 20, // Reduced space between columns
                              columns: [
                                DataColumn(label: Container(width: idColumnWidth, child: Text('Id'))),
                                DataColumn(label: Container(width: nameColumnWidth, child: Text('Name'))),
                                DataColumn(label: Container(width: priceColumnWidth, child: Text('Price'))),
                                DataColumn(label: Container(width: actionsColumnWidth, child: Text('Actions'))),
                              ],
                              rows: _products.map((product) {
                                final productId = product['id'].toString();
                                final truncatedId = productId.length > 3
                                    ? productId.substring(productId.length - 3)
                                    : productId;
                                return DataRow(cells: [
                                  DataCell(Container(width: idColumnWidth, child: Text(truncatedId))),
                                  DataCell(Container(
                                    width: nameColumnWidth,
                                    child: Text(
                                      product['name'].length > 8
                                          ? '${product['name'].substring(0, 8)}...'
                                          : product['name'],
                                    ),
                                  )),
                                  DataCell(Container(width: priceColumnWidth, child: Text('${product['price']} \₹'))),
                                  DataCell(Container(
                                    width: actionsColumnWidth,
                                    child: IconButton(
                                      icon: Icon(Icons.close, color: Colors.red),
                                      onPressed: () => _deleteProduct(product['id'].toString()),
                                    ),
                                  )),
                                ]);
                              }).toList(),
                            ),
                          if (_products.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('No products available'),
                            ),
                          SizedBox(height: 80), // Add space for the button
                        ],
                      ),
                    );
                  },
                ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddProductScreen(camera: widget.camera),
                  ),
                );
                if (result == true) {
                  _fetchProducts();
                }
              },
              child: Text('Add Product'),
            ),
          ),
        ],
      ),
    );
  }
}