import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:milan_hackathon/utils/notification_manager.dart';
import 'package:milan_hackathon/utils/route_generator.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalNotifications.init();
  await Firebase.initializeApp();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IITH Community App',
      theme: ThemeData.dark(),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      onUnknownRoute: (settings) {
        return RouteGenerator.generateRoute(const RouteSettings(name: '/'));
      },
      navigatorObservers: [routeObserver],
    );
  }
}
