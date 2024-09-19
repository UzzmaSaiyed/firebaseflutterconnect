import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebaseflutterconnect/product.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new product in Firestore
  Future<void> create(Product product) async {
    try {
      await _firestore.collection("product").add(product.toMap());
    } catch (e) {
      log("Error creating product: ${e.toString()}");
    }
  }

  // Fetch all products from Firestore
  Future<List<Product>> read() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection("product").get();
      return snapshot.docs
          .map((doc) =>
              Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      log("Error reading products: ${e.toString()}");
      return [];
    }
  }

  // Update an existing product by ID
  Future<void> update(String productId, Product updatedProduct) async {
    try {
      await _firestore
          .collection("product")
          .doc(productId)
          .update(updatedProduct.toMap());
    } catch (e) {
      log("Error updating product: ${e.toString()}");
    }
  }

  // Delete a product by ID
  Future<void> delete(String productId) async {
    try {
      await _firestore.collection("product").doc(productId).delete();
    } catch (e) {
      log("Error deleting product: ${e.toString()}");
    }
  }
}
