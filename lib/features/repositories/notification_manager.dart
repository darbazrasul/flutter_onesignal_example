import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_onesignal_example/features/service/notification_service.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// A helper class to easily manage notification setup and handling
class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  late NotificationService _notificationService;
  late GoRouter _router;
  bool _isInitialized = false;

  /// Initialize the notification service with the app's router
  Future<bool> initialize(GoRouter router) async {
    if (_isInitialized) return true;

    _router = router;
    _notificationService = NotificationServiceImpl();

    // Initialize the notification service
    final result = await _notificationService.initialize();
    if (!result) return false;

    // Request permission
    await _notificationService.requestPermission();

    // Set up handlers
    _setupNotificationHandlers();

    // Register for iOS background notifications if on iOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _registerIOSBackgroundNotifications();
    }

    _isInitialized = true;
    return true;
  }

  /// Set up notification handlers to handle clicks and displays
  void _setupNotificationHandlers() {
    _notificationService.setNotificationHandlers(
      onClicked: _handleNotificationClick,
      onReceived: _handleNotificationReceived,
      onLocalClicked: _handleLocalNotificationClick,
    );
  }

  /// Register for iOS background notifications
  void _registerIOSBackgroundNotifications() {
    // This sets up a callback for when the app is in the background
    // iOS specific setup for handling notifications when app is in background
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      debugPrint('NotificationManager: Setting up iOS background handlers');

      // Set up background message handler for iOS
      OneSignal.Notifications.clearAll;
    }
  }

  /// Handle when a notification is clicked
  void _handleNotificationClick(OSNotificationClickEvent event) {
    debugPrint('NotificationManager: Notification clicked');
    final data = event.notification.additionalData;
    _notificationService.handleNotificationNavigation(_router, data);
  }

  /// Handle when a notification is received (while app is in foreground)
  void _handleNotificationReceived(OSNotificationWillDisplayEvent event) {
    debugPrint('NotificationManager: Notification received in foreground');
    // We're already showing a local notification in the service, so no need to do anything here

    // For iOS, we can add additional handling if needed
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Additional iOS-specific handling can be added here
      debugPrint('NotificationManager: iOS foreground notification received');
    }
  }

  /// Handle when a local notification is clicked
  void _handleLocalNotificationClick(NotificationResponse response) {
    debugPrint('NotificationManager: Local notification clicked');
    if (response.payload == null) return;

    try {
      final Map<String, dynamic> data = jsonDecode(response.payload!);
      _notificationService.handleNotificationNavigation(_router, data);
    } catch (e) {
      debugPrint('NotificationManager: Error parsing payload - $e');
    }
  }

  /// iOS-specific method to handle notifications when the app is terminated
  Future<void> checkForInitialNotification() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      debugPrint('NotificationManager: Checking for initial iOS notification');

      // Get details of any notification that launched the app
      final NotificationAppLaunchDetails? launchDetails =
          await FlutterLocalNotificationsPlugin()
              .getNotificationAppLaunchDetails();

      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        debugPrint('NotificationManager: App launched by notification');

        if (launchDetails.notificationResponse?.payload != null) {
          try {
            final Map<String, dynamic> data = jsonDecode(
              launchDetails.notificationResponse!.payload!,
            );

            // Delay navigation slightly to ensure app is fully initialized
            Future.delayed(const Duration(milliseconds: 500), () {
              _notificationService.handleNotificationNavigation(_router, data);
            });
          } catch (e) {
            debugPrint(
              'NotificationManager: Error parsing launch payload - $e',
            );
          }
        }
      }
    }
  }

  /// Get the player ID for sending targeted notifications
  Future<String?> getPlayerId() {
    return _notificationService.getPlayerId();
  }

  /// Add tags to the user for segmentation
  Future<void> addTags(Map<String, dynamic> tags) {
    return _notificationService.addTags(tags);
  }

  /// Remove tags from the user
  Future<void> removeTags(List<String> tagKeys) {
    return _notificationService.removeTags(tagKeys);
  }

  // Manage notification subscription
  Future<void> subscribeNotication() {
    return _notificationService.subscribeToPushNotifications();
  }

  // Manage notification unsubscription
  Future<void> unsubscribeNotifcation() {
    return _notificationService.unsubscribeFromPushNotifications();
  }

  /// Show a local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) {
    return _notificationService.showLocalNotification(
      title: title,
      body: body,
      payload: payload,
    );
  }

  /// iOS-specific: Reset badge count
  Future<void> resetBadgeCount() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
    }
  }

  /// iOS-specific: Set badge count
  Future<void> setBadgeCount(int count) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
    }
  }

  /// iOS-specific: Request critical notification permission
  Future<bool> requestCriticalPermission() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final bool? result = await FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
      return result ?? false;
    }
    return false;
  }
}
