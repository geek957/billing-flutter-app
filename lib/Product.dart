class Product {
  final String id;
  final String imagePath;
  final String name;
  final int quantity;
  final int price;

  Product({this.id = "101",this.name = "test", this.imagePath = "", this.quantity = 1, this.price = 10});
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'imagePath': imagePath,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}