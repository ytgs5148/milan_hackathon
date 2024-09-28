import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:milan_hackathon/utils/auth_service.dart';
import 'package:milan_hackathon/utils/item_manager.dart';

class CreateItemForm extends StatefulWidget {

  const CreateItemForm({
    super.key,
  });

  @override
  State<CreateItemForm> createState() => _CreateItemFormState();
}

class _CreateItemFormState extends State<CreateItemForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final ItemManager _itemManager = ItemManager();
  final AuthService _authService = AuthService();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 25
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _addProduct() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _priceController.text.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      await _itemManager.createItem(
        _titleController.text,
        int.parse(_priceController.text),
        base64Image,
        _descriptionController.text,
        currentUser.email!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new item'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 27, 13, 50),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: <Widget>[
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.deepPurple.withOpacity(0.1),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.deepPurple.withOpacity(0.1),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Price',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[800],
                        prefixText: '₹ ',
                      ),
                      keyboardType: TextInputType.number,
                      controller: _priceController,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Upload Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 16, 117, 125),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    if (_imageFile != null) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _imageFile!.readAsBytesSync(),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _addProduct,
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Post'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 41, 104, 43),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ),
        ]
      ),
    );
  }
}