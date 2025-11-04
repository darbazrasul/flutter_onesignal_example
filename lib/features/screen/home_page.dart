import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => context.push('/notification-demo'),
          icon: const Icon(Icons.notifications_active),
          label: const Text('Test Notifications'),
        ),
      ),
    );
  }
}
