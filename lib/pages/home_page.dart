// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:milan_hackathon/components/bottom_bar.dart';
import 'package:milan_hackathon/components/create_post.dart';
import 'package:milan_hackathon/components/post.dart';
import 'package:milan_hackathon/components/top_bar.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: ListView.builder(
        itemCount: 2,
        itemBuilder: (context, index) {
          return Post(context: context, index: index);
        },
      ),
      floatingActionButton: const CreatePost(),
      bottomNavigationBar: BottomBar(currentIndex: _selectedIndex, onItemTapped: _onItemTapped),
    );
  }
}
