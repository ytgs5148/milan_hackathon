import 'package:flutter/material.dart';
import 'package:milan_hackathon/pages/chat_page.dart';
import 'package:milan_hackathon/pages/home_page.dart';
import 'package:milan_hackathon/pages/chat_detail_page.dart';
import 'package:milan_hackathon/pages/map_page.dart';
import 'package:milan_hackathon/pages/profile_page.dart';
import 'package:milan_hackathon/pages/shop_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final Uri uri = Uri.parse(settings.name ?? '');
    final String path = uri.path;
    final String? emailId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;

    if (path == '/') {
      return MaterialPageRoute(builder: (_) => const HomePage());
    } else if (path == '/home') {
      return MaterialPageRoute(builder: (_) => const HomePage());
    } else if (path == '/chats') {
      return MaterialPageRoute(builder: (_) => const ChatPage());
    } else if (path == '/shop') {
      return MaterialPageRoute(builder: (_) => const ShopPage());
    } else if (path == '/profile') {
      return MaterialPageRoute(builder: (_) => const ProfilePage());
    } else if (path == '/map') {
      return MaterialPageRoute(builder: (_) => const MapPage());
    } else if (path.startsWith('/chat/') && emailId != null) {
      return MaterialPageRoute(builder: (_) => ChatDetailPage(email: emailId));
    } else {
      return errorRoute('Route not found');
    }
  }

  static Route<dynamic> errorRoute(String message) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'ERROR: $message',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.red,
                ),
              ),
              FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(_, '/', (route) => false);
                },
                label: const Text(
                  'Go Back',
                  style: TextStyle(fontSize: 26, fontFamily: 'ShortStack'),
                ),
                icon: const Icon(Icons.arrow_forward),
                backgroundColor: const Color.fromRGBO(97, 239, 159, 0.612),
                foregroundColor: Colors.white,
              )
            ],
          ),
        ),
      );
    });
  }
}