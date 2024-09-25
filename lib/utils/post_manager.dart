import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createComment(String postId, String userId, String content) async {
    try {
      final comment = {
        'userId': userId,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('posts').doc(postId).collection('comments').add(comment);
    } catch (e) {
      log('Error creating comment: $e');
    }
  }

  Stream<QuerySnapshot> fetchPosts() {
    try {
      return _firestore.collection('posts').orderBy('timestamp', descending: true).snapshots();
    } catch (e) {
      log('Error fetching posts: $e');
      rethrow;
    }
  }

  Future<void> upvotePost(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final postSnapshot = await postRef.get();

      if (postSnapshot.exists) {
        final postData = postSnapshot.data() as Map<String, dynamic>;
        final upvotes = List<String>.from(postData['upvotes'] ?? []);
        final downvotes = List<String>.from(postData['downvotes'] ?? []);

        if (!upvotes.contains(userId)) {
          upvotes.add(userId);
          downvotes.remove(userId);
        } else {
          upvotes.remove(userId);
        }

        await postRef.update({
          'upvotes': upvotes,
          'downvotes': downvotes,
        });
      }
    } catch (e) {
      log('Error upvoting post: $e');
    }
  }

  Future<void> downvotePost(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final postSnapshot = await postRef.get();

      if (postSnapshot.exists) {
        final postData = postSnapshot.data() as Map<String, dynamic>;
        final upvotes = List<String>.from(postData['upvotes'] ?? []);
        final downvotes = List<String>.from(postData['downvotes'] ?? []);

        if (!downvotes.contains(userId)) {
          downvotes.add(userId);
          upvotes.remove(userId);
        } else {
          downvotes.remove(userId);
        }

        await postRef.update({
          'upvotes': upvotes,
          'downvotes': downvotes,
        });
      }
    } catch (e) {
      log('Error downvoting post: $e');
    }
  }
}