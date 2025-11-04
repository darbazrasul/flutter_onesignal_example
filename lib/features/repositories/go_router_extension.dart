import 'package:flutter/material.dart';
import 'package:flutter_onesignal_example/features/screen/notification_demo_page.dart';
import 'package:go_router/go_router.dart';
// ... your other imports

/// Example of how to add the NotificationDemoPage to your GoRouter configuration
///
/// Add this route to your existing router setup in app_routers.dart

class AppRouter {
  static final GoRouter router = GoRouter(
    // Your existing configuration...
    routes: [
      // ... your existing routes

      // Add this route for the notification demo page
      GoRoute(
        path: '/notification-demo',
        name: 'notificationDemo',
        builder: (context, state) => const NotificationDemoPage(),
      ),

      // Or if you want it nested under a parent route:
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'notification-demo',
            name: 'notificationDemo',
            builder: (context, state) => const NotificationDemoPage(),
          ),
        ],
      ),

      // ... rest of your routes
    ],
  );
}

/// Example: Add button to navigate to demo page from anywhere
///
/// Usage examples:

// 1. Simple navigation button
class NavigateToNotificationDemo extends StatelessWidget {
  const NavigateToNotificationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        context.push('/notification-demo');
      },
      icon: const Icon(Icons.notifications_active),
      label: const Text('Test Notifications'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}

// 2. Drawer menu item
class NotificationDemoDrawerItem extends StatelessWidget {
  const NotificationDemoDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.notifications_active),
      title: const Text('Notification Demo'),
      subtitle: const Text('Test OneSignal notifications'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(context); // Close drawer
        context.push('/notification-demo');
      },
    );
  }
}

// 3. Settings page option
class SettingsNotificationOption extends StatelessWidget {
  const SettingsNotificationOption({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Icon(Icons.notifications, color: Colors.white),
        ),
        title: const Text(
          'Notification Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Manage push notifications and test'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          context.push('/notification-demo');
        },
      ),
    );
  }
}

// 4. Floating Action Button (for debug builds)
class NotificationDemoFAB extends StatelessWidget {
  const NotificationDemoFAB({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!const bool.fromEnvironment('dart.vm.product')) {
      return FloatingActionButton(
        onPressed: () {
          context.push('/notification-demo');
        },
        backgroundColor: Colors.deepPurple,
        tooltip: 'Notification Demo',
        child: const Icon(Icons.notifications_active),
      );
    }
    return const SizedBox.shrink();
  }
}

// 5. App Bar action
class NotificationDemoAppBarAction extends StatelessWidget {
  const NotificationDemoAppBarAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications_active),
      onPressed: () {
        context.push('/notification-demo');
      },
      tooltip: 'Notification Demo',
    );
  }
}

/// Example: Complete Settings Page with Notification Demo option
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Other settings...

          // Notification Demo Section
          const SizedBox(height: 16),
          Text(
            'Notifications',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: const Text('Notification Demo'),
                  subtitle: const Text('Test and manage push notifications'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.push('/notification-demo');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notification Settings'),
                  subtitle: const Text('Configure notification preferences'),
                  trailing: Switch(
                    value: true, // Your actual value
                    onChanged: (value) {
                      // Handle toggle
                    },
                  ),
                ),
              ],
            ),
          ),

          // Other settings...
        ],
      ),
    );
  }
}

/// Example: Debug Menu with Notification Demo
class DebugMenu extends StatelessWidget {
  const DebugMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show in debug builds
    if (const bool.fromEnvironment('dart.vm.product')) {
      return const SizedBox.shrink();
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text(
              'Debug Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Notification Demo'),
            onTap: () {
              Navigator.pop(context);
              context.push('/notification-demo');
            },
          ),
          // Add other debug options...
        ],
      ),
    );
  }
}

/// Example: Bottom Sheet Quick Access
void showNotificationQuickAccess(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Notifications',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.science, color: Colors.white),
              ),
              title: const Text('Test Notifications'),
              subtitle: const Text('Demo page for testing OneSignal'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pop(context);
                context.push('/notification-demo');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

/// Example: How to use in your existing app
/// 
/// Option 1: Add to your home page
/// ```dart
/// FloatingActionButton(
///   onPressed: () => context.push('/notification-demo'),
///   child: const Icon(Icons.notifications),
/// )
/// ```
///
/// Option 2: Add to drawer
/// ```dart
/// const NotificationDemoDrawerItem()
/// ```
///
/// Option 3: Add to settings
/// ```dart
/// const SettingsNotificationOption()
/// ```
///
/// Option 4: Add to app bar
/// ```dart
/// const NotificationDemoAppBarAction()
/// ```