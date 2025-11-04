import 'package:flutter/material.dart';
import 'package:flutter_onesignal_example/features/screen/notification_demo_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: NotificationDemoPage());
  }
}
