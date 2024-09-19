import 'package:firebaseflutterconnect/auth_service.dart';
import 'package:firebaseflutterconnect/database_service.dart';
import 'package:firebaseflutterconnect/loginscreen.dart';
import 'package:firebaseflutterconnect/product.dart';
import 'package:flutter/material.dart';

class ProductCrud extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product CRUD',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProductCRUD(),
    );
  }
}

class ProductCRUD extends StatefulWidget {
  @override
  _ProductCRUDState createState() => _ProductCRUDState();
}

class _ProductCRUDState extends State<ProductCRUD> {
  final _auth = AuthService();
  final _dbService = DatabaseService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _nameController2 = TextEditingController();
  final TextEditingController _quantityController2 = TextEditingController();
  final TextEditingController _descriptionController2 = TextEditingController();

  bool flag = false;

  List<Product> _products = [];
  bool _showProducts = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addProduct() {
    if (_nameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    } else {
      flag = true;
      final newProduct = Product(
        name: _nameController.text,
        quantity: int.parse(_quantityController.text),
        description: _descriptionController.text,
      );

      _dbService.create(newProduct);
      _nameController.clear();
      _quantityController.clear();
      _descriptionController.clear();
    }

    if (flag == true) {
      _fetchProducts();
    }
  }

  void _updateProduct(Product product) {
    _nameController2.text = product.name;
    _quantityController2.text = product.quantity.toString();
    _descriptionController2.text = product.description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController2,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _descriptionController2,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _quantityController2,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantity'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedProduct = Product(
                  productId: product.productId,
                  name: _nameController2.text,
                  quantity: int.parse(_quantityController2.text),
                  description: _descriptionController2.text,
                );
                _dbService.update(product.productId!, updatedProduct);
                Navigator.pop(context);
                _fetchProducts();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _fetchProducts() async {
    final products = await _dbService.read();
    setState(() {
      _products = products;
      _showProducts = true;
    });
  }

  void _deleteProduct(String productId) {
    _dbService.delete(productId);
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Disable back navigation
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            title: Text('Product CRUD'),
            actions: [
              IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () async {
                    await _auth.logoutUser();
                    goToLogin(context);
                  }),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Quantity'),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _addProduct,
                      child: Text("Add"),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _fetchProducts,
                      child: Text("Show"),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showProducts = false;
                        });
                      },
                      child: Text("Hide"),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (_showProducts)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Card(
                          child: ListTile(
                            title: Text(product.name),
                            subtitle: Text(
                              'Quantity: ${product.quantity}\nDescription: ${product.description}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _updateProduct(product);
                                  },
                                ),
                                IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Delete Product'),
                                              content: Text(
                                                  'Are you sure you want to delete this product?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text('No'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    _deleteProduct(
                                                        product.productId!);
                                                  },
                                                  child: Text('Yes'),
                                                ),
                                              ],
                                            );
                                          });
                                    }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ));
  }

  goToLogin(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
}
