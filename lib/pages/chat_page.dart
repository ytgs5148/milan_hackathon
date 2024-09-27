import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:milan_hackathon/components/chats_list.dart';
import 'package:milan_hackathon/components/bottom_bar.dart';
import 'package:milan_hackathon/components/group_chats.dart';
import 'package:milan_hackathon/components/top_bar.dart';
import 'package:milan_hackathon/models/chat.dart';
import 'package:milan_hackathon/utils/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _searchQuery = '';
  int _selectedIndex = 1;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final authService = AuthService();
    final user = await authService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

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
        Navigator.pushNamed(context, '/shop');
        break;
      case 3:
        Navigator.pushNamed(context, '/map');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: const TopBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                if (_currentUser != null && _currentUser!.email!.endsWith('iith.ac.in'))
                  StreamBuilder<QuerySnapshot>(
                    stream: authService.getGroupChatsStream(),
                    builder: (context, groupSnapshot) {
                      if (groupSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (groupSnapshot.hasError) {
                        return const Center(child: Text('Error loading group chats'));
                      } else if (!groupSnapshot.hasData || groupSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No group chats available. Login using IITH mail.'));
                      } else {
                        final List<Map<String, dynamic>> chats = groupSnapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
                        final List<Chat> groupChats = chats.map((chat) => Chat.fromJson(chat)).toList();

                        return GroupsChatList(
                          groupChats: groupChats,
                          searchQuery: _searchQuery,
                        );
                      }
                    }
                  )
                else
                  const SizedBox.shrink(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: authService.getUserProfiles(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error loading chats'));
                      } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('Not logged in. Log in by clicking on the top right corner.'));
                      } else {
                        final List<Map<String, dynamic>> chats = (snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
                        chats.removeWhere((chat) => chat['email'].toString().endsWith('chat.com'));

                        return ChatsList(
                          chats: chats,
                          searchQuery: _searchQuery,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomBar(currentIndex: _selectedIndex, onItemTapped: _onItemTapped),
    );
  }
}