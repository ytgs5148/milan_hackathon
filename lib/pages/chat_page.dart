import 'package:flutter/material.dart';
import 'package:milan_hackathon/components/new_chat_popup.dart';
import 'package:milan_hackathon/components/bottom_bar.dart';
import 'package:milan_hackathon/components/filter_dialog.dart';
import 'package:milan_hackathon/components/top_bar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _filterBranch = '';
  String _filterYear = '';
  String _searchQuery = '';
  int _selectedIndex = 1;

  List<Map<String, dynamic>> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    _chats = [
      {'name': 'John Doe', 'lastMessage': 'Hey, how are you?', 'branch': 'CSE', 'year': '3'},
      {'name': 'Jane Smith', 'lastMessage': 'Did you finish the assignment?', 'branch': 'ME', 'year': '2'},
      {'name': 'Alice Johnson', 'lastMessage': 'Let\'s meet at the library', 'branch': 'EE', 'year': '4'},
    ];
    setState(() {});
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          filterBranch: _filterBranch,
          filterYear: _filterYear,
          onApply: (String branch, String year) {
            setState(() {
              _filterBranch = branch;
              _filterYear = year;
            });
          },
        );
      },
    );
  }

  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NewChatPopup(
          onStartChat: (String email) {
            Navigator.pushNamed(context, '/chat/$email');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredChats = _chats.where((chat) {
      return chat['name'].toLowerCase().contains(_searchQuery.toLowerCase()) &&
          (_filterBranch.isEmpty || chat['branch'] == _filterBranch) &&
          (_filterYear.isEmpty || chat['year'] == _filterYear);
    }).toList();

    return Scaffold(
      appBar: const TopBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredChats.length,
              itemBuilder: (context, index) {
                final chat = filteredChats[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(chat['name'][0]),
                  ),
                  title: Text(chat['name']),
                  subtitle: Text(chat['lastMessage']),
                  onTap: () {
                    String email = chat['name'].replaceAll(' ', '.').toLowerCase() + '@iith.ac.in';
                    Navigator.pushNamed(context, '/chat/$email');
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewChatDialog,
        child: const Icon(Icons.chat),
      ),
      bottomNavigationBar: BottomBar(currentIndex: _selectedIndex, onItemTapped: _onItemTapped),
    );
  }
}