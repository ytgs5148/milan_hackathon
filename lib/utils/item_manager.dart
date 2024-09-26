import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milan_hackathon/models/items.dart';

class ItemManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createItem(String name, int price, String image, String description, String authorEmail) async {
    try {
      final String itemId = DateTime.now().millisecondsSinceEpoch.toString();
      final item = {
        'itemId': itemId,
        'name': name,
        'price': price,
        'image': image,
        'description': description,
        'authorEmail': authorEmail,
        'createdAtTimestamp': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('items').doc(itemId).set(item);
    } catch (e) {
      log('Error creating item: $e');
    }
  }

  Future<Items?> fetchItem(String itemId) async {
    try {
      final itemSnapshot = await _firestore.collection('items').doc(itemId).get();
      if (itemSnapshot.exists && itemSnapshot.data() != null) {
        final itemData = itemSnapshot.data() as Map<String, dynamic>;
        return Items.fromMap(itemData);
      } else {
        log('Item does not exist or data is null');
        return null;
      }
    } catch (e) {
      log('Error fetching item: $e');
      return null;
    }
  }

  Stream<QuerySnapshot> fetchItems() {
    try {
      return _firestore.collection('items').orderBy('createdAtTimestamp', descending: true).snapshots();
    } catch (e) {
      log('Error fetching items: $e');
      rethrow;
    }
  }

  Future<void> updateItem(String itemId, String name, int price, String image, String description) async {
    try {
      final itemRef = _firestore.collection('items').doc(itemId);
      await itemRef.update({
        'name': name,
        'price': price,
        'image': image,
        'description': description,
      });
    } catch (e) {
      log('Error updating item: $e');
    }
  }

  Future<void> deleteItem(String authorEmail, String itemName) async {
    try {
      final itemSnapshot = await _firestore.collection('items').where('authorEmail', isEqualTo: authorEmail).where('name', isEqualTo: itemName).get();
      if (itemSnapshot.docs.isNotEmpty) {
        await itemSnapshot.docs.first.reference.delete();
      } else {
        log('Item not found');
      }
    } catch (e) {
      log('Error deleting item: $e');
    }
  }

  Future<void> addItemComment(String itemId, String authorEmail, String content) async {
    try {
      final comment = {
        'itemId': itemId,
        'authorEmail': authorEmail,
        'comment': content,
        'timestamp': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('items').doc(itemId).collection('comments').add(comment);
    } catch (e) {
      log('Error adding comment to item: $e');
    }
  }

  Future<Items?> getItemById(String itemId) async {
    try {
      final itemSnapshot = await _firestore.collection('items').doc(itemId).get();
      if (itemSnapshot.exists && itemSnapshot.data() != null) {
        final itemData = itemSnapshot.data() as Map<String, dynamic>;
        return Items.fromMap(itemData);
      } else {
        throw Exception('Item does not exist or data is null');
      }
    } catch (e) {
      log('Error fetching item by ID: $e');
      rethrow;
    }
  }
}
