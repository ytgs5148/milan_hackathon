import 'package:flutter/material.dart';

class NewChatPopup extends StatefulWidget {
  final Function(String) onStartChat;

  const NewChatPopup({
    super.key,
    required this.onStartChat,
  });

  @override
  _NewChatPopupState createState() => _NewChatPopupState();
}

class _NewChatPopupState extends State<NewChatPopup> {
  String email = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start New Chat'),
      content: TextField(
        onChanged: (value) {
          setState(() {
            email = value;
          });
        },
        decoration: const InputDecoration(hintText: "Enter user's email"),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Start Chat'),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onStartChat(email);
          },
        ),
      ],
    );
  }
}