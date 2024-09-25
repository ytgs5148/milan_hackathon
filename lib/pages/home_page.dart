import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:milan_hackathon/components/bottom_bar.dart';
import 'package:milan_hackathon/components/create_post_button.dart';
import 'package:milan_hackathon/models/post.dart';
import 'package:milan_hackathon/utils/post_manager.dart';
import 'package:milan_hackathon/components/top_bar.dart';
import 'package:milan_hackathon/components/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PostManager _postManager = PostManager();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/chats');
        break;
      case 2:
        Navigator.pushNamed(context, '/discussions');
        break;
      case 3:
        Navigator.pushNamed(context, '/resources');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  Future<void> _refreshPosts() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: StreamBuilder<QuerySnapshot>(
          stream: _postManager.fetchPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading posts'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No posts available'));
            } else {
              final posts = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Post.fromMap(data);
              }).toList();

              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostCard(
                    context: context,
                    index: index,
                    post: post,
                  );
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomBar(currentIndex: _selectedIndex, onItemTapped: _onItemTapped),
      floatingActionButton: const CreatePost(),
    );
  }
}