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
        FutureBuilder(
          future: auth.getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasData) {
              final user = snapshot.data;
              return PopupMenuButton<String>(
                icon: CircleAvatar(
                    backgroundImage: NetworkImage(
                    user!.photoURL ?? 'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png',
                    ),
                ),
                onSelected: (String result) async {
                  switch (result) {
                    case 'Profile':
                      Navigator.pushNamed(context, '/profile');
                      break;
                    case 'Logout':
                      await auth.signOut();
                      Navigator.pushNamed(context, '/');
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Logout',
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                    ),
                  ),
                ],
              );
            } else {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.person),
                onSelected: (String result) async {
                  if (result == 'Login') {
                    final user = await auth.loginWithGoogle();
                    if (user != null) {
                      Navigator.pushNamed(context, '/');
                    }
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
                ],
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}