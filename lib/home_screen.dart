import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase CRUD')),
      body: StreamBuilder(
        stream: _users.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final data = snapshot.requireData;

          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(data.docs[index]['name']),
                subtitle: Text(data.docs[index]['email']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        final TextEditingController _nameController =
                            TextEditingController(
                                text: data.docs[index]['name']);
                        final TextEditingController _emailController =
                            TextEditingController(
                                text: data.docs[index]['email']);

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Update User'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: _nameController,
                                    decoration:
                                        InputDecoration(labelText: 'Name'),
                                  ),
                                  TextField(
                                    controller: _emailController,
                                    decoration:
                                        InputDecoration(labelText: 'Email'),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    _users.doc(data.docs[index].id).update({
                                      'name': _nameController.text,
                                      'email': _emailController.text,
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Update'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _users.doc(data.docs[index].id).delete();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addUser(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _addUser(BuildContext context) async {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _users.add({
                  'name': _nameController.text,
                  'email': _emailController.text,
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
