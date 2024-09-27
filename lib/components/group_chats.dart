import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:milan_hackathon/models/chat.dart';
import 'package:milan_hackathon/utils/auth_service.dart';
import 'package:milan_hackathon/main.dart';

class GroupsChatList extends StatefulWidget {
  final List<Chat> groupChats;
  final String searchQuery;

  const GroupsChatList({
    super.key,
    required this.groupChats,
    required this.searchQuery,
  });

  @override
  _GroupsChatListState createState() => _GroupsChatListState();
}

class _GroupsChatListState extends State<GroupsChatList> with RouteAware {
  final _auth = AuthService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final User? user = await _auth.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
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
    if (_currentUser == null || _currentUser?.email == null) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Chat> filteredGroupChats = widget.groupChats.where((chat) {
      final chatMail = chat.participants?.firstWhere((email) => email.endsWith('chat.com'), orElse: () => '');

      if (chatMail == null || chatMail == '') return false;

      return chatMail.toLowerCase().contains(widget.searchQuery.toLowerCase());
    }).toList();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: filteredGroupChats.length,
      itemBuilder: (context, index) {
        final chat = filteredGroupChats[index];
        final chatMail = chat.participants?.firstWhere((email) => email.endsWith('chat.com'));

        String groupName = '';

        if (chatMail == null) {
          return const SizedBox.shrink();
        }

        if (chatMail.endsWith('bchat.com')) {
          groupName = (chatMail.replaceAll('@bchat.com', '')).toUpperCase();
        } else if (chatMail.endsWith('ychat.com')) {
          groupName = 'Year ${chatMail.replaceAll('@ychat.com', '')}';
        } else {
          String firstElem = chatMail.replaceAll('@chat.com', '');
          String year = firstElem.substring(firstElem.length - 2);
          String branch = firstElem.substring(0, firstElem.length - 2);

          groupName = '${branch.toUpperCase()} Year $year';
        }

        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.group),
          ),
          title: Text(groupName),
          subtitle: const Text('Group Chat'),
          onTap: () {
            Navigator.pushNamed(context, '/chat/$chatMail');
          },
        );
      },
    );
  }
}