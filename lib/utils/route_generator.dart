import 'package:flutter/material.dart';
import 'package:milan_hackathon/pages/chat_page.dart';
import 'package:milan_hackathon/pages/home_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String args = settings.arguments.toString();

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/chats':
        return MaterialPageRoute(builder: (_) => const ChatPage());
      default:
        return errorRoute(args);
    }
  }

  static Route<dynamic> errorRoute(String args) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'ERROR: $args',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.red,
                ),
              ),
              FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(_, '/', (route) => false, arguments: args);
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
        )
      );
    });
  }
}