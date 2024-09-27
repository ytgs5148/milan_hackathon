import 'package:flutter/material.dart';
import 'package:milan_hackathon/components/bottom_bar.dart';
import 'package:milan_hackathon/models/user.dart' as user_model;
import 'package:milan_hackathon/utils/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _auth = AuthService();

  User? googleUser;
  user_model.User? _currentUser;
  int currentIndex = 4;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = await _auth.getCurrentUser();
    user_model.User? fireUser = await _auth.getUserData(user?.email ?? '');
    setState(() {
      _currentUser = fireUser;
      googleUser = user;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/chats');
        break;
      case 2:
        Navigator.pushNamed(context, '/shop');
        break;
      case 3:
        Navigator.pushNamed(context, '/map');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(_currentUser?.profilePhoto ?? 'https://example.com/default-avatar.png'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentUser!.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentUser!.email,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: googleUser?.phoneNumber == null
                              ? Colors.grey[800]
                              : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        constraints: const BoxConstraints(minHeight: 50),
                        child: Text(
                          'Phone Number: ${googleUser?.phoneNumber ?? 'Not available'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: googleUser?.phoneNumber == null ? Colors.grey : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        constraints: const BoxConstraints(minHeight: 50),
                        child: Text(
                          'UID: ${googleUser?.uid ?? 'Not available'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _currentUser!.branch.isEmpty
                              ? Colors.grey[800]
                              : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        constraints: const BoxConstraints(minHeight: 50),
                        child: Text(
                          'Branch: ${_currentUser!.branch.isNotEmpty ? _currentUser!.branch : 'Login with IITH email to view this data'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: _currentUser!.branch.isEmpty ? Colors.grey : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: _currentUser!.year.isEmpty
                              ? Colors.grey[800]
                              : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[800]!),
                        ),
                        constraints: const BoxConstraints(minHeight: 50),
                        child: Text(
                          'Year: ${_currentUser!.year != '' ? _currentUser!.year.toString() : 'Login with IITH email to view this data'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: _currentUser!.year.isEmpty ? Colors.grey : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        await _auth.signOut();
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 152, 64, 57),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomBar(currentIndex: currentIndex, onItemTapped: _onItemTapped),
    );
  }

}
