import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:milan_hackathon/components/bottom_bar.dart';
import 'package:milan_hackathon/models/chat.dart';
import 'package:milan_hackathon/models/message.dart';
import 'package:milan_hackathon/models/user.dart' as user_model;
import 'package:milan_hackathon/utils/auth_service.dart';
import 'package:milan_hackathon/components/loading_screen.dart';

class ChatDetailPage extends StatefulWidget {
  final String email;

  const ChatDetailPage({super.key, required this.email});

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final AuthService _auth = AuthService();
  user_model.User? _currentUser;
  user_model.User? _receiverUser;

  int selectedIndex = 1;

  void onItemTapped(int index) async {
    setState(() {
      selectedIndex = index;
    });
    if (index == 1) {
      final currentUser = await _auth.getCurrentUser();
      if (currentUser == null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoadingScreen(),
          ),
        );
        final userCredential = await _auth.loginWithGoogle();
        if (userCredential != null) {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/chats');
        } else {
          Navigator.pop(context);
          _showLoginPopup();
        }
      } else {
        Navigator.pushNamed(context, '/chats');
      }
    } else {
      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/home');
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
  }

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final currentUser = await _auth.getCurrentUser();
    if (currentUser != null) {
      final receiverUser = await _auth.getUserData(widget.email);
      if (mounted) {
        setState(() {
          _currentUser = user_model.User(
            name: currentUser.displayName ?? '',
            email: currentUser.email ?? '',
            profilePhoto: currentUser.photoURL ?? '',
            branch: '',
            year: '',
          );
          _receiverUser = receiverUser;
        });
      }
    } else {
      _showLoginPopup();
    }
  }

  List<ChatMessage> _generateChatMessageList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      return ChatMessage(
        user: ChatUser(
          id: _currentUser!.email == m.senderEmail ? _currentUser!.email : _receiverUser!.email,
          firstName: _currentUser!.email == m.senderEmail ? _currentUser!.name : _receiverUser!.name,
          profileImage: _currentUser!.email == m.senderEmail ? _currentUser!.profilePhoto : _receiverUser!.profilePhoto,
        ),
        createdAt: m.sentAt!.toDate(),
        text: m.content ?? '',
      );
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return chatMessages;
  }

  void _showLoginPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please log in to continue.'),
          actions: [
            TextButton(
              onPressed: () async {
                final user = await _auth.loginWithGoogle();
                if (user != null) {
                  Navigator.of(context).pop();
                  if (mounted) {
                    _initializeChat();
                  }
                }
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            title: Row(
              children: [
                if (_receiverUser?.profilePhoto != null && _receiverUser!.profilePhoto.isNotEmpty)
                  CircleAvatar(
                    backgroundImage: NetworkImage(_receiverUser!.profilePhoto),
                  ),
                const SizedBox(width: 10),
                Text(_receiverUser?.name ?? 'Unknown'),
              ],
            ),
          ),
          if (_currentUser != null && _receiverUser != null)
            Expanded(
              child: StreamBuilder<Chat?>(
                stream: _auth.getChatData(_currentUser!.email, _receiverUser!.email),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    Chat chat = snapshot.data!;
                    List<ChatMessage> messages = _generateChatMessageList(chat.messages!);

                    return DashChat(
                      messages: messages,
                      currentUser: ChatUser(
                        id: _currentUser!.email,
                        firstName: _currentUser!.name,
                        profileImage: _currentUser!.profilePhoto,
                      ),
                      messageOptions: MessageOptions(
                        showOtherUsersAvatar: true,
                        showTime: true,
                        messageDecorationBuilder: (ChatMessage msg, ChatMessage? prevMsg, ChatMessage? nextMsg) {
                          bool isUser = msg.user.id == _currentUser!.email;
                          return BoxDecoration(
                            color: isUser ? Colors.blue[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          );
                        },
                      ),
                      inputOptions: InputOptions(
                        inputDecoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Type a message',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          contentPadding: const EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        inputTextStyle: const TextStyle(color: Colors.black),
                        sendButtonBuilder: (onSend) {
                          return Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.auto_awesome),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () {
                                  onSend();
                                },
                              ),
                            ],
                          );
                        },
                        alwaysShowSend: true,
                        autocorrect: true,
                      ),
                      onSend: (ChatMessage chatMessage) async {
                        Message message = Message(
                          senderEmail: _currentUser!.email,
                          receiverEmail: _receiverUser?.email ?? 'unknown',
                          content: chatMessage.text,
                          messageType: MessageType.Text,
                          sentAt: Timestamp.fromDate(chatMessage.createdAt),
                        );
                        await _auth.sendMessage(message);
                      },
                    );
                  } else {
                    return const Center(child: Text('No data available.'));
                  }
                },
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: BottomBar(currentIndex: selectedIndex, onItemTapped: onItemTapped),
    );
  }
}