import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onesignal_example/features/di/app.dart';
import 'package:flutter_onesignal_example/features/router/go_router_extension.dart';
import 'package:flutter_onesignal_example/features/repositories/notification_manager.dart';
import 'package:flutter_onesignal_example/features/service/notification_service.dart';

Future<void> run([
  List<DeviceOrientation> orientations = const [DeviceOrientation.portraitUp],
]) async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  final notificationManager = NotificationManager();
  final isInitialized = await notificationManager.initialize(AppRouter.router);
  final notificationService = NotificationServiceImpl();
  await notificationService.requestPermission();

  // await notificationService.initialize();
  // notificationService.setNotificationHandlers(
  //   onClicked: (event) {
  //     final data = event.notification.additionalData;
  //     if (data != null) {
  //       notificationService.handleNotificationNavigation(
  //         AppRouter.router,
  //         data,
  //       );
  //     }
  //   },
  //   onReceived: (event) {
  //     debugPrint(
  //       'Notification received in foreground: ${event.notification.title}',
  //     );
  //   },
  // );

  if (isInitialized) {
    debugPrint(
      '================================ NotificationManager initialized successfully ================================',
    );
    await notificationManager.checkForInitialNotification();
  } else {
    debugPrint(
      '================================ NotificationManager initialization failed    ================================',
    );
  }

  runApp(const MyApp());
}
