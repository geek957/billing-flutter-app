class Product {
  final String id;
  final String imagePath;
  final String name;
  final int quantity;
  final int cost;

  Product({this.id = "101",this.name = "test", required this.imagePath, this.quantity = 1, this.cost = 10});
}