import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:milan_hackathon/models/post.dart';
import 'package:milan_hackathon/models/user.dart' as user_model;
import 'package:milan_hackathon/utils/auth_service.dart';
import 'package:milan_hackathon/utils/post_manager.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';

class PostCard extends StatefulWidget {
  final int index;
  final BuildContext context;
  final Post post;

  const PostCard({
    super.key,
    required this.context,
    required this.index,
    required this.post,
  });

  @override
  State<PostCard> createState() => _PostState();
}

class _PostState extends State<PostCard> {
  late Future<user_model.User?> _userProfileFuture;
  late Future<User?> _currentlyLoggedInUserProfileFuture;
  late Post _post;

  final postmanager = PostManager();

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _userProfileFuture = AuthService().getUserData(_post.authorEmail);
    _currentlyLoggedInUserProfileFuture = AuthService().getCurrentUser();
  }

  int getVoteCount() {
    return _post.upvotedBy.length - _post.downvotedBy.length;
  }

  Future<void> updateVoteCount(int amt) async {
    user_model.User? user = await _userProfileFuture;
    User? currentUser = await _currentlyLoggedInUserProfileFuture;

    if (currentUser == null || user == null || currentUser.email == null) {
      ScaffoldMessenger.of(widget.context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to vote on a post'),
        ),
      );
      return;
    }

    if (_post.upvotedBy.contains(currentUser.email)) {
      await postmanager.removeUpvoteFromPost(_post.postId, currentUser.email!);
      if (amt == -1) {
        await postmanager.downvotePost(_post.postId, currentUser.email!);
      }
    } else if (_post.downvotedBy.contains(currentUser.email!)) {
      await postmanager.removeDownvoteFromPost(_post.postId, currentUser.email!);
      if (amt == 1) {
        await postmanager.upvotePost(_post.postId, currentUser.email!);
      }
    } else {
      if (amt == 1) {
        await postmanager.upvotePost(_post.postId, currentUser.email!);
      } else {
        await postmanager.downvotePost(_post.postId, currentUser.email!);
      }
    }

    Post? updatedPost = await postmanager.fetchPost(_post.postId);

    if (updatedPost == null) return;

    setState(() {
      _post = updatedPost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Ensure left alignment
        children: [
          ListTile(
            leading: FutureBuilder<user_model.User?>(
              future: _userProfileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircleAvatar(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const CircleAvatar(
                    child: Icon(Icons.error),
                  );
                } else {
                  final user = snapshot.data!;
                  return CircleAvatar(
                    backgroundImage: NetworkImage(user.profilePhoto),
                  );
                }
              },
            ),
            title: FutureBuilder<user_model.User?>(
              future: _userProfileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...');
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const Text('Error loading user');
                } else {
                  final user = snapshot.data!;
                  return Text(user.name);
                }
              },
            ),
            subtitle: Text(timeago.format(DateTime.fromMillisecondsSinceEpoch(_post.postedAtTimestamp))),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Ensure left alignment
              children: [
                Text(_post.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8.0),
                Text(_post.description),
                if (_post.imageUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Image.memory(
                        base64Decode(_post.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Text('Image not available'));
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          FutureBuilder<User?>(
            future: _currentlyLoggedInUserProfileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError || !snapshot.hasData) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_upward),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You need to be logged in to vote on a post'),
                              ),
                            );
                          }, // Disable voting
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('${getVoteCount()}'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_downward),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You need to be logged in to vote on a post'),
                              ),
                            );
                          }, // Disable voting
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () {
                            // TODO: Show comments
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.auto_awesome),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('AI Summary'),
                                  content: const Text('This is an AI-generated summary of the post.'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                final currentUser = snapshot.data!;
                final hasUpvoted = _post.upvotedBy.contains(currentUser.email);
                final hasDownvoted = _post.downvotedBy.contains(currentUser.email);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_upward,
                            color: hasUpvoted ? Colors.green[300] : null,
                          ),
                          onPressed: () {
                            updateVoteCount(1);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('${getVoteCount()}', style: TextStyle(
                            color: getVoteCount() > 0 ? Colors.green[500] : getVoteCount() < 0 ? Colors.red[500] : null,
                          ),),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_downward,
                            color: hasDownvoted ? Colors.red[300] : null,
                          ),
                          onPressed: () {
                            updateVoteCount(-1);
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () {
                            showDialog(context: context, builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Comments'),
                                content: const Text('This is a placeholder for the comments section.'),
                                actions: [
                                  TextButton(
                                    child: const Text('Close'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.auto_awesome),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('AI Summary'),
                                  content: const Text('This is an AI-generated summary of the post.'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}