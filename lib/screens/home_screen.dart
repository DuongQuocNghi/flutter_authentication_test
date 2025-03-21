import 'package:flutter/material.dart';
import 'package:flutter_authentication_test/models/user.dart';

class HomeScreen extends StatelessWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('home_screen'),
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            key: const Key('menu_button'),
            icon: const Icon(Icons.menu),
            onPressed: () {
              _showMenu(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            Text(
              'Welcome',
            ),
            Text(
              key: const Key('user_greeting'),
              'Welcome, ${user.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(user.email, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 32),
            const Text(
              'You have successfully logged in!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              key: const Key('logout_button'),
              onPressed: () => _handleLogout(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('LOG OUT'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to profile screen (not implemented)
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings screen (not implemented)
                },
              ),
              ListTile(
                key: const Key('logout_button'),
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Log out'),
                onTap: () {
                  Navigator.pop(context);
                  _handleLogout(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    // Return to login screen
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
