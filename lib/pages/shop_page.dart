import 'package:flutter/material.dart';
import 'package:milan_hackathon/components/bottom_bar.dart';
import 'package:milan_hackathon/components/create_item_form.dart';
import 'package:milan_hackathon/components/item_card.dart';
import 'package:milan_hackathon/components/top_bar.dart';
import 'package:milan_hackathon/models/items.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milan_hackathon/utils/auth_service.dart';
import 'package:milan_hackathon/utils/item_manager.dart';
import 'package:milan_hackathon/models/user.dart' as user_model;

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final int currentIndex = 2;
  final ItemManager _itemManager = ItemManager();
  final AuthService _authService = AuthService();

  void onItemTapped(int index) {
    if (index != currentIndex) {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/chats');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/resources');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/maps');
          break;
      }
    }
  }

  void _showAddProductModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          heightFactor: 0.6,
          child: CreateItemForm(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _itemManager.fetchItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No items available'));
          } else {
            final items = snapshot.data!.docs.map((doc) => Items.fromMap(doc.data() as Map<String, dynamic>)).toList();
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return FutureBuilder<user_model.User?>(
                  future: _authService.getUserData(item.authorEmail),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(
                        leading: CircleAvatar(
                          child: CircularProgressIndicator(),
                        ),
                        title: Text('Loading...'),
                      );
                    } else if (userSnapshot.hasError || !userSnapshot.hasData) {
                      return const ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.error),
                        ),
                        title: Text('Error loading user'),
                      );
                    } else {
                      final user = userSnapshot.data!;
                      return ItemCard(user: user, item: item);
                    }
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProductModal(context);
        },
        backgroundColor: const Color.fromARGB(255, 56, 27, 107),
        child: const Icon(Icons.create),
      ),
      bottomNavigationBar: BottomBar(currentIndex: currentIndex, onItemTapped: onItemTapped),
    );
  }
}
