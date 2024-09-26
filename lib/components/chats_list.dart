import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:milan_hackathon/utils/auth_service.dart';
import 'package:milan_hackathon/main.dart';

class ChatsList extends StatefulWidget {
  final List<Map<String, dynamic>> chats;
  final String searchQuery;

  const ChatsList({
    super.key,
    required this.chats,
    required this.searchQuery,
  });

  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> with RouteAware {
  final _auth = AuthService();

  Stream<Map<String, dynamic>> fetchLastMessage(String receiverEmail) async* {
    try {
      log('Fetching last message for $receiverEmail');
      final currentUser = await _auth.getCurrentUser();
      await for (var chat in _auth.getChatData(currentUser!.email!, receiverEmail)) {
        log('Chat data: $chat $currentUser $receiverEmail');
        if (chat != null && chat.messages != null && chat.messages!.isNotEmpty) {
          final lastMessage = chat.messages!.last;
          log(lastMessage.content.toString());
          yield {
            'content': lastMessage.content == null ? 'No content' : lastMessage.content?.replaceAll('\n', ' '),
            'isSentByUser': lastMessage.senderEmail == currentUser.email,
          };
        } else {
          yield {
            'content': '',
            'isSentByUser': false,
          };
        }
      }
    } catch (e) {
      log('Error fetching last message: $e');
      yield {
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
    setState(() {});
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
          subtitle: StreamBuilder<Map<String, dynamic>>(
            stream: fetchLastMessage(receiverEmail),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading...');
              } else if (snapshot.hasError) {
                return const Text('Error loading message');
              } else {
                final lastMessage = snapshot.data ?? {'content': '', 'isSentByUser': false};
                final content = lastMessage['content'] as String;
                final isSentByUser = lastMessage['isSentByUser'] as bool;

                return content != ''
                  ? Row(
                      children: [
                        if (isSentByUser) const Icon(Icons.check, size: 16),
                        const SizedBox(width: 4),
                        Text(content.length > 35 ? '${content.substring(0, 35)}...' : content),
                      ],
                    )
                  : const Text(
                      'Click to start a conversation',
                      style: TextStyle(fontStyle: FontStyle.italic),
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