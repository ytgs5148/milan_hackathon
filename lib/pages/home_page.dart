import 'package:flutter/material.dart';
import 'package:milan_hackathon/components/bottom_bar.dart';
import 'package:milan_hackathon/components/create_post_button.dart';
import 'package:milan_hackathon/components/post_card.dart';
import 'package:milan_hackathon/components/top_bar.dart';
import 'package:milan_hackathon/interfaces/post.dart';
import 'package:milan_hackathon/interfaces/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    List<Post> posts = [
      Post(postId: 'ahsafhfb214', title: 'Lambda IITH Milan Hackathon', description: 'This is a sample post content. It can be an announcement or a user post.', author: User(name: 'IITH', email: 'iith@gmail.com', branch: 'CS', year: '1'), postedAtTimestamp: 1727161903, imageUrl: 'https://i.imgur.com/PYmSceZ.png', votes: 10, comments: []),
      Post(postId: 'ahsafhfb214', title: 'Lambda IITH Milan Hackathon 2', description: 'This is a sample post content. It can be an announcement or a user post.', author: User(name: 'IITH', email: 'iith@gmail.com', branch: 'CS', year: '1'), postedAtTimestamp: 1727147503, imageUrl: 'https://i.imgur.com/PYmSceZ.png', votes: 10, comments: []),
    ];

    return Scaffold(
      appBar: const TopBar(),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(context: context, index: index, post: posts[index],);
        },
      ),
      floatingActionButton: const CreatePost(),
      bottomNavigationBar: BottomBar(currentIndex: _selectedIndex, onItemTapped: _onItemTapped),
    );
  }
}
