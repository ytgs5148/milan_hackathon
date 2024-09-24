import 'package:flutter/material.dart';
import 'package:milan_hackathon/components/bottom_bar.dart';
import 'package:milan_hackathon/components/chat_screen_header.dart';
import 'package:milan_hackathon/interfaces/user.dart';
import 'package:milan_hackathon/utils/api.dart'; // Import the API service

class ChatDetailPage extends StatefulWidget {
  final String emailId;

  const ChatDetailPage({super.key, required this.emailId});

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  User? _userData;
  bool _isLoading = true;

  bool _showAiOptions = false;
  int _selectedIndex = 1;

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
  void initState() {
    super.initState();
    _fetchUserData();
    // Simulating some initial messages
    _messages.add({'sender': 'other', 'message': 'Hello!', 'timestamp': DateTime.now().subtract(const Duration(minutes: 5))});
    _messages.add({'sender': 'me', 'message': 'Hi there!', 'timestamp': DateTime.now().subtract(const Duration(minutes: 4))});
    _messages.add({'sender': 'other', 'message': 'How are you?', 'timestamp': DateTime.now().subtract(const Duration(minutes: 3))});
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await ApiService.fetchUserData(widget.emailId);
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load user data: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendMessage(String message) {
    setState(() {
      _messages.add({'sender': 'me', 'message': message, 'timestamp': DateTime.now()});
      _messageController.clear();
    });
  }

  void _applyAiTool(String tool) {
    String currentText = _messageController.text;
    switch (tool) {
      case 'Make text professional':
        _messageController.text = 'Dear recipient, $currentText';
        break;
      case 'Make text casual':
        _messageController.text = 'Hey! $currentText';
        break;
    }
    setState(() {
      _showAiOptions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: ChatScreenHeader(userData: _userData),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[_messages.length - 1 - index];
                  return Align(
                    alignment: message['sender'] == 'me' ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: message['sender'] == 'me' ? Colors.blue[700] : Colors.grey[800],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(message['message']),
                          const SizedBox(height: 4),
                          Text(
                            '${message['timestamp'].hour}:${message['timestamp'].minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_showAiOptions)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.grey[850],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _applyAiTool('Make text professional'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                      child: const Text('Make text professional'),
                    ),
                    ElevatedButton(
                      onPressed: () => _applyAiTool('Make text casual'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      child: const Text('Make text casual'),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: Colors.grey[900],
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.auto_awesome),
                    onPressed: () {
                      setState(() {
                        _showAiOptions = !_showAiOptions;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_messageController.text.isNotEmpty) {
                        _sendMessage(_messageController.text);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomBar(currentIndex: _selectedIndex, onItemTapped: _onItemTapped),
      ),
    );
  }
}