import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milan_hackathon/models/items.dart';
import 'package:milan_hackathon/models/user.dart' as user_model;
import 'package:intl/intl.dart';
import 'package:milan_hackathon/utils/auth_service.dart';
import 'package:milan_hackathon/utils/item_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemCard extends StatefulWidget {
  const ItemCard({
    super.key,
    required this.user,
    required this.item,
  });

  final user_model.User user;
  final Items item;

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  final AuthService _authService = AuthService();

  void _showBuyDialog(BuildContext context) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Purchase'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to buy this item?'),
              const SizedBox(height: 16),
              Text('Item: ${widget.item.name}'),
              Text('Price: ₹${NumberFormat('#,##,###').format(widget.item.price)}'),
              Text('Seller: ${widget.user.name}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!mounted) return;
                Navigator.of(context).pop();
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: widget.user.email,
                  query: 'subject=${Uri.encodeComponent('Purchase request for ${widget.item.name}')}'
                      '&body=${Uri.encodeComponent('Hi ${widget.user.name},\n\nI would like to purchase the item "${widget.item.name}" for ₹${widget.item.price}. Please let me know if it is still available.\n\nThanks!')}',
                );

                try {
                  await launchUrl(emailUri);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not launch email client: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.send, size: 16),
                  SizedBox(width: 4),
                  Text('Send a message!'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final User? user = await _authService.getCurrentUser();

                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error deleting item')),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item deleted successfully')),
                );
                await ItemManager().deleteItem(user.email!, widget.item.name);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _isAuthor() async {
    final currentUser = await _authService.getCurrentUser();
    return currentUser?.email == widget.item.authorEmail;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAuthor(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        } else {
          final isAuthor = snapshot.data ?? false;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.memory(
                    base64Decode(widget.item.image),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.item.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(widget.user.profilePhoto),
                            radius: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.user.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${NumberFormat('#,##,###').format(widget.item.price)}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          ElevatedButton(
                            onPressed: () => isAuthor ? _showDeleteDialog(context) : _showBuyDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAuthor ? Colors.red : const Color.fromARGB(255, 25, 89, 102),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(isAuthor ? 'Delete' : 'Buy Now'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}