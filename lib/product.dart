class Product {
  String? productId; // Firestore document ID
  String name;
  int quantity;
  String description;

  Product({
    this.productId,
    required this.name,
    required this.quantity,
    required this.description,
  });

  // Convert Product object to a Map for Firestore
  Map<String, dynamic> toMap() => {
        "name": name,
        "quantity": quantity,
        "description": description,
      };

  // Factory method to create a Product from Firestore data
  factory Product.fromMap(Map<String, dynamic> data, String id) {
    return Product(
      productId: id,
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
      description: data['description'] ?? '',
    );
  }
}
