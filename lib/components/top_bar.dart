import 'package:flutter/material.dart';
import 'package:milan_hackathon/utils/auth_service.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return AppBar(
      title: const Text('IITH Community'),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.person),
          onSelected: (String result) {
            switch (result) {
              case 'Login':
                Navigator.pushNamed(context, '/login');
                break;
              case 'Profile':
                Navigator.pushNamed(context, '/profile');
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'Login',
              child: ListTile(
                leading: Icon(Icons.login),
                title: Text('Login'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'Profile',
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}