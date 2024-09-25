import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milan_hackathon/models/post.dart';

class PostManager {
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

  Stream<QuerySnapshot> fetchPosts() {
    try {
      return _firestore.collection('posts').orderBy('postedAtTimestamp', descending: true).snapshots();
    } catch (e) {
      log('Error fetching posts: $e');
      rethrow;
    }
  }

  Future<Post?> fetchPost(String postId) async {
    try {
      final postSnapshot = await _firestore.collection('posts').doc(postId).get();
      log('Document ID: ${postSnapshot.id}');
      log('Document Data: ${postSnapshot.data()}');
      log('Document Exists: ${postSnapshot.exists}');
      if (postSnapshot.exists && postSnapshot.data() != null) {
        final postData = postSnapshot.data() as Map<String, dynamic>;
        return Post.fromMap(postData);
      } else {
        log('Post does not exist or data is null');
        return null;
      }
    } catch (e) {
      log('Error fetching post: $e');
      return null;
    }
  }

  Future<void> removeUpvoteFromPost(String postId, String userEmail) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final postSnapshot = await postRef.get();

      if (postSnapshot.exists && postSnapshot.data() != null) {
        final postData = postSnapshot.data() as Map<String, dynamic>;
        final upvotedBy = List<String>.from(postData['upvotedBy'] ?? []);

        if (upvotedBy.contains(userEmail)) {
          upvotedBy.remove(userEmail);
        }

        await postRef.update({
          'upvotedBy': upvotedBy,
        });
      } else {
        log('Post does not exist or data is null');
      }
    } catch (e) {
      log('Error removing upvote from post: $e');
    }
  }

  Future<void> removeDownvoteFromPost(String postId, String userEmail) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final postSnapshot = await postRef.get();

      if (postSnapshot.exists && postSnapshot.data() != null) {
        final postData = postSnapshot.data() as Map<String, dynamic>;
        final downvotedBy = List<String>.from(postData['downvotedBy'] ?? []);

        if (downvotedBy.contains(userEmail)) {
          downvotedBy.remove(userEmail);
        }

        await postRef.update({
          'downvotedBy': downvotedBy,
        });
      } else {
        log('Post does not exist or data is null');
      }
    } catch (e) {
      log('Error removing downvote from post: $e');
    }
  }

  Future<void> upvotePost(String postId, String userEmail) async {
    try {
      final postQuery = _firestore.collection('posts').where('postId', isEqualTo: postId).limit(1);
      final postSnapshot = await postQuery.get();

      if (postSnapshot.docs.isNotEmpty) {
        final postRef = postSnapshot.docs.first.reference;
        final postData = postSnapshot.docs.first.data();
        final upvotedBy = List<String>.from(postData['upvotedBy'] ?? []);
        final downvotedBy = List<String>.from(postData['downvotedBy'] ?? []);

        if (!upvotedBy.contains(userEmail)) {
          upvotedBy.add(userEmail);
          downvotedBy.remove(userEmail);
        } else {
          upvotedBy.remove(userEmail);
        }

        await postRef.update({
          'upvotedBy': upvotedBy,
          'downvotedBy': downvotedBy,
        });
      } else {
        log('Post does not exist or data is null');
      }
    } catch (e) {
      log('Error upvoting post: $e');
    }
  }

  Future<void> downvotePost(String postId, String userEmail) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final postSnapshot = await postRef.get();

      if (postSnapshot.exists && postSnapshot.data() != null) {
        final postData = postSnapshot.data() as Map<String, dynamic>;
        final upvotedBy = List<String>.from(postData['upvotedBy'] ?? []);
        final downvotedBy = List<String>.from(postData['downvotedBy'] ?? []);

        if (!downvotedBy.contains(userEmail)) {
          downvotedBy.add(userEmail);
          upvotedBy.remove(userEmail);
        } else {
          downvotedBy.remove(userEmail);
        }

        await postRef.update({
          'upvotedBy': upvotedBy,
          'downvotedBy': downvotedBy,
        });
      } else {
        log('Post does not exist or data is null');
      }
    } catch (e) {
      log('Error downvoting post: $e');
    }
  }

  Future<void> createPost(String title, String description, String authorEmail, String imageUrl) async {
    final String postId = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final post = {
        'postId': postId,
        'title': title,
        'description': description,
        'authorEmail': authorEmail,
        'postedAtTimestamp': (DateTime.now().microsecondsSinceEpoch).truncate(),
        'imageUrl': imageUrl,
        'upvotedBy': [],
        'downvotedBy': [],
        'comments': [],
      };
      await _firestore.collection('posts').doc(postId).set(post);
    } catch (e) {
      log('Error creating post: $e');
    }
  }

  Future<Post> getPostById(String postId) async {
    try {
      final postSnapshot = await _firestore.collection('posts').doc(postId).get();
      log('Document ID: ${postSnapshot.id}');
      log('Document Data: ${postSnapshot.data()}');
      log('Document Exists: ${postSnapshot.exists}');
      if (postSnapshot.exists && postSnapshot.data() != null) {
        final postData = postSnapshot.data() as Map<String, dynamic>;
        return Post.fromMap(postData);
      } else {
        throw Exception('Post does not exist or data is null');
      }
    } catch (e) {
      log('Error fetching post by ID: $e');
      rethrow;
    }
  }
}