import 'package:flutter/material.dart';
import 'package:milan_hackathon/models/user.dart';

class ChatScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  final User? userData;

  const ChatScreenHeader({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(userData != null ? userData!.name : 'Chat'),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}