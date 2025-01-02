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
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_products.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text('Id')),
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Price')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: _products.map((product) {
                              return DataRow(cells: [
                                DataCell(Text(product['id'].toString().substring(6-3))),
                                DataCell(Text(
                                  product['name'].length > 7
                                      ? '${product['name'].substring(0, 7)}...'
                                      : product['name'],
                                )),
                                DataCell(Text('${product['price']} \₹')),
                                DataCell(
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () => _deleteProduct(product['id'].toString()),
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      if (_products.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('No products available'),
                        ),
                      SizedBox(height: 80), // Add space for the button
                    ],
                  ),
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