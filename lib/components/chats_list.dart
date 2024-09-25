import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:milan_hackathon/utils/auth_service.dart';
import 'package:milan_hackathon/main.dart'; // Import the main.dart file to access the routeObserver

class ChatsList extends StatefulWidget {
  final List<Map<String, dynamic>> chats;
  final String searchQuery;

  ChatsList({
    super.key,
    required this.chats,
    required this.searchQuery,
  });

  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> with RouteAware {
  final _auth = AuthService();

  Future<Map<String, dynamic>> fetchLastMessage(String receiverEmail) async {
    try {
      log('Fetching last message for $receiverEmail');
      final currentUser = await _auth.getCurrentUser();
      final chat = await _auth.getChatData(currentUser!.email!, receiverEmail).first;
      log('Chat data: $chat $currentUser $receiverEmail');
      if (chat != null && chat.messages != null && chat.messages!.isNotEmpty) {
        final lastMessage = chat.messages!.last;
        log(lastMessage.content.toString());
        return {
          'content': lastMessage.content ?? 'No content',
          'isSentByUser': lastMessage.senderEmail == currentUser.email,
        };
      } else {
        return {
          'content': '',
          'isSentByUser': false,
        };
      }
    } catch (e) {
      log('Error fetching last message: $e');
      return {
        'content': 'Error loading message',
        'isSentByUser': false,
      };
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute<dynamic>);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the current route has been popped off, and the user returns to this route.
    setState(() {
      // Trigger a rebuild to refresh the last messages.
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredChats = widget.chats.where((chat) {
      return chat['name'].toLowerCase().contains(widget.searchQuery.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredChats.length,
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        final receiverEmail = chat['email'];

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(chat['profilePhoto']),
            child: chat['profilePhoto'] == null || chat['profilePhoto'].isEmpty ? Text(chat['name'][0]) : null,
          ),
          title: Text(chat['name']),
          subtitle: FutureBuilder<Map<String, dynamic>>(
            future: fetchLastMessage(receiverEmail),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading...');
              } else if (snapshot.hasError) {
                return const Text('Error loading message');
              } else {
                final lastMessage = snapshot.data ?? {'content': '', 'isSentByUser': false};
                final content = lastMessage['content'] as String;
                final isSentByUser = lastMessage['isSentByUser'] as bool;

                return Text(
                  content != ''
                      ? (isSentByUser ? '✓ $content' : content)
                      : 'Click to start a conversation',
                  style: content == '' ? const TextStyle(fontStyle: FontStyle.italic) : null,
                );
              }
            },
          ),
          onTap: () {
            String email = chat['email'];
            Navigator.pushNamed(context, '/chat/$email', arguments: email);
          },
        );
      },
    );
  }
}