import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:milan_hackathon/components/post_card.dart';
import 'package:milan_hackathon/models/user.dart';
import 'package:milan_hackathon/utils/auth_service.dart';
import 'package:milan_hackathon/utils/comment_manager.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentList extends StatefulWidget {
  const CommentList({
    super.key,
    required this.widget,
  });

  final PostCard widget;

  @override
  _CommentListState createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSending = false;
  List<QueryDocumentSnapshot> _comments = [];
  bool _isLoadingComments = true;

  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      final snapshot = await CommentManager().fetchComments(widget.widget.post.postId).first;
      setState(() {
        _comments = snapshot.docs;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingComments = false;
      });
      log('Error fetching comments: $e');
    }
  }

  void _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isSending = true;
    });

    final user = await _auth.getCurrentUser();

    if (user == null) {
      setState(() {
        _isSending = false;
      });
      return;
    }

    await CommentManager().createComment(
      widget.widget.post.postId,
      user.email ?? '',
      _commentController.text,
    );

    setState(() {
      _isSending = false;
      _commentController.clear();
      _fetchComments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: _isLoadingComments
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Comments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _comments.isEmpty
                        ? const Center(child: Text('No Comments yet'))
                        : ListView(
                            children: _comments.map((doc) {
                              final commentData = doc.data() as Map<String, dynamic>;
                              return FutureBuilder(
                                future: _auth.getUserData(commentData['authorEmail']),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                                    return const ListTile(
                                      leading: CircleAvatar(
                                        child: CircularProgressIndicator(),
                                      ),
                                      title: Text('Loading...'),
                                    );
                                  } else if (userSnapshot.hasError) {
                                    return const ListTile(
                                      leading: CircleAvatar(
                                        child: Icon(Icons.error),
                                      ),
                                      title: Text('Error loading user'),
                                    );
                                  } else {
                                    final commenterData = userSnapshot.data as User;
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(commenterData.profilePhoto),
                                        child: commenterData.profilePhoto.isEmpty
                                            ? const Icon(Icons.person)
                                            : null,
                                      ),
                                      title: Text(commenterData.name),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(commentData['comment']),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            timeago.format((commentData['timestamp'] as Timestamp).toDate()),
                                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Add a comment...',
                            ),
                            onTap: () => FocusScope.of(context).requestFocus(),
                          ),
                        ),
                        _isSending
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              )
                            : IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: _sendComment,
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}