import 'package:flutter/material.dart';
import 'package:flutter_onesignal_example/features/router/app_routes.dart';
import 'package:flutter_onesignal_example/features/screen/home_page.dart';
import 'package:flutter_onesignal_example/features/screen/notification_demo_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/',
        name: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/notification-demo',
        name: AppRoutes.notificationDemo,
        builder: (context, state) => const NotificationDemoPage(),
      ),
    ],
  );
}
