import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milan_hackathon/models/comments.dart';

class CommentManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createComment(String postId, String authorEmail, String content) async {
    try {
      final comment = {
        'postId': postId,
        'authorEmail': authorEmail,
        'comment': content,
        'timestamp': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('posts').doc(postId).collection('comments').add(comment);
    } catch (e) {
      log('Error creating comment: $e');
    }
  }

  Stream<QuerySnapshot> fetchComments(String postId) {
    try {
      return _firestore.collection('posts').doc(postId).collection('comments').orderBy('timestamp', descending: true).snapshots();
    } catch (e) {
      log('Error fetching comments: $e');
      rethrow;
    }
  }

  Future<Comments?> fetchComment(String postId, String commentId) async {
    try {
      final commentSnapshot = await _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).get();
      log('Document ID: ${commentSnapshot.id}');
      log('Document Data: ${commentSnapshot.data()}');
      log('Document Exists: ${commentSnapshot.exists}');
      if (commentSnapshot.exists && commentSnapshot.data() != null) {
        final commentData = commentSnapshot.data() as Map<String, dynamic>;
        return Comments.fromMap(commentData);
      } else {
        log('Comment does not exist or data is null');
        return null;
      }
    } catch (e) {
      log('Error fetching comment: $e');
      return null;
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).delete();
    } catch (e) {
      log('Error deleting comment: $e');
    }
  }

  Future<void> updateComment(String postId, String commentId, String newContent) async {
    try {
      await _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).update({
        'comment': newContent,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error updating comment: $e');
    }
  }
}