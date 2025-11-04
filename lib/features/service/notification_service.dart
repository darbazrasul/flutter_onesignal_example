import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';

typedef NotificationClickHandler =
    void Function(OSNotificationClickEvent event);
typedef NotificationReceiveHandler =
    void Function(OSNotificationWillDisplayEvent event);
typedef LocalNotificationClickHandler =
    void Function(NotificationResponse response);

abstract class NotificationService {
  Future<bool> initialize();
  Future<String?> getPlayerId();
  Future<bool> requestPermission();
  void setNotificationHandlers({
    required NotificationClickHandler onClicked,
    required NotificationReceiveHandler onReceived,
    LocalNotificationClickHandler? onLocalClicked,
  });
  Future<void> addTags(Map<String, dynamic> tags);
  Future<void> removeTags(List<String> tagKeys);
  Future<void> subscribeToPushNotifications();
  Future<void> unsubscribeFromPushNotifications();
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  });

  // Simplified navigation method using extension
  void handleNotificationNavigation(
    GoRouter router,
    Map<String, dynamic>? data,
  );
}

class NotificationServiceImpl implements NotificationService {
  static const String _oneSignalAppId = '82776dd3-cb77-4c69-8d81-cac99c6499ba';
  bool _isInitialized = false;

  // Local notifications plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Notification channels
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDescription =
      'Channel for important notifications';

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      debugPrint('OneSignal: Starting initialization...');

      // Initialize OneSignal
      OneSignal.initialize(_oneSignalAppId);

      // Enable verbose logging in debug mode
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      // Add permission observer
      OneSignal.Notifications.addPermissionObserver((state) {
        debugPrint('OneSignal: Permission state changed: $state');
      });

      // Add subscription observer
      OneSignal.User.pushSubscription.addObserver((state) {
        debugPrint(
          'OneSignal: Subscription state changed: ${state.current.id}',
        );
        debugPrint('OneSignal: Opted in: ${state.current.optedIn}');
        debugPrint('OneSignal: Token: ${state.current.token}');
      });

      // Log initial subscription state
      final subscriptionState = OneSignal.User.pushSubscription;
      debugPrint('OneSignal: Initial Player ID: ${subscriptionState.id}');
      debugPrint('OneSignal: Initial Opted in: ${subscriptionState.optedIn}');

      // Initialize local notifications
      await _initializeLocalNotifications();

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('OneSignal: Failed to initialize: $e');
      return false;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings with properly configured properties
      DarwinInitializationSettings initializationSettingsIOS =
          const DarwinInitializationSettings(
            requestAlertPermission: false, // We'll request this separately
            requestBadgePermission: false, // We'll request this separately
            requestSoundPermission: false, // We'll request this separately
            notificationCategories: <DarwinNotificationCategory>[
              DarwinNotificationCategory(
                _channelId,
                options: <DarwinNotificationCategoryOption>{
                  DarwinNotificationCategoryOption.allowAnnouncement,
                },
              ),
            ],
          );

      // Initialization settings
      InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Create notification channel for Android
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(
              const AndroidNotificationChannel(
                _channelId,
                _channelName,
                description: _channelDescription,
                importance: Importance.high,
              ),
            );
      }

      debugPrint('Local Notifications: Initialization complete');
    } catch (e) {
      debugPrint('Local Notifications: Failed to initialize: $e');
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      // Request OneSignal permission
      final oneSignalPermission =
          await OneSignal.Notifications.requestPermission(false);

      // Request local notification permission
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final bool? result = await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
              critical: true,
            );
        debugPrint('iOS Local Notification Permission result: $result');
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidFlutterLocalNotificationsPlugin? androidImpl =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        final bool? granted = await androidImpl
            ?.requestNotificationsPermission();
        debugPrint('Android Local Notification Permission result: $granted');
      }

      debugPrint('OneSignal: Permission request result: $oneSignalPermission');
      return oneSignalPermission;
    } catch (e) {
      debugPrint('OneSignal: Failed to request permission: $e');
      return false;
    }
  }

  @override
  Future<String?> getPlayerId() async {
    try {
      final id = OneSignal.User.pushSubscription.id;
      debugPrint('OneSignal: Current Player ID: $id');
      return id;
    } catch (e) {
      debugPrint('OneSignal: Failed to get player ID: $e');
      return null;
    }
  }

  @override
  void setNotificationHandlers({
    required NotificationClickHandler onClicked,
    required NotificationReceiveHandler onReceived,
    LocalNotificationClickHandler? onLocalClicked,
  }) {
    // Set local notification click handler if provided
    if (onLocalClicked != null) {
      _setLocalNotificationClickHandler(onLocalClicked);
    }

    // Add foreground notification handler
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('OneSignal: Notification received in foreground:');
      debugPrint('Title: ${event.notification.title}');
      debugPrint('Body: ${event.notification.body}');
      debugPrint('Data: ${event.notification.additionalData}');

      // Display as local notification
      _showOneSignalAsLocalNotification(event.notification);

      // Call the handler
      onReceived(event);

      // Prevent default display to show our local notification instead
      event.preventDefault();
    });

    // Add notification click handler
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('OneSignal: Notification clicked:');
      debugPrint('Title: ${event.notification.title}');
      debugPrint('Body: ${event.notification.body}');
      debugPrint('Data: ${event.notification.additionalData}');

      // Call the handler
      onClicked(event);
    });
  }

  void _setLocalNotificationClickHandler(
    LocalNotificationClickHandler onLocalClicked,
  ) async {
    // Re-initialize to add click handler
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    DarwinInitializationSettings initializationSettingsIOS =
        const DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onLocalClicked,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotification,
    );
  }

  // Background notification handler
  static void _onBackgroundNotification(NotificationResponse details) {
    // This is only used to register the background handler
    // The actual logic should be implemented in the calling code
    debugPrint('Handling notification in background: ${details.payload}');
  }

  Future<void> _showOneSignalAsLocalNotification(
    OSNotification notification,
  ) async {
    try {
      // Create notification details
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            badgeNumber: 1,
            threadIdentifier: 'thread_id',
            categoryIdentifier: 'default_category',
            interruptionLevel: InterruptionLevel.active,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Parse the additional data for payload
      String payload = '';
      if (notification.additionalData != null) {
        payload = jsonEncode(notification.additionalData);
      }

      // Show notification
      await _flutterLocalNotificationsPlugin.show(
        notification.notificationId.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: payload,
      );

      debugPrint('Local Notification: Displayed from OneSignal notification');
    } catch (e) {
      debugPrint('Local Notification: Failed to show notification: $e');
    }
  }

  @override
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    try {
      // Create notification details
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            badgeNumber: 1,
            threadIdentifier: 'thread_id',
            categoryIdentifier: 'default_category',
            interruptionLevel: InterruptionLevel.active,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Convert payload to JSON string if provided
      String? payloadStr;
      if (payload != null) {
        payloadStr = jsonEncode(payload);
      }

      // Generate a unique ID based on timestamp
      final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      // Show notification
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payloadStr,
      );

      debugPrint('Local Notification: Manual notification displayed');
    } catch (e) {
      debugPrint('Local Notification: Failed to show notification: $e');
    }
  }

  // Subscribe to a specific topic/category
  @override
  Future<void> addTags(Map<String, dynamic> tags) async {
    try {
      await OneSignal.User.addTags(tags);
      debugPrint('OneSignal: Tags added: $tags');
    } catch (e) {
      debugPrint('OneSignal: Failed to add tags: $e');
      rethrow;
    }
  }

  // Unsubscribe from a specific topic/category
  @override
  Future<void> removeTags(List<String> tagKeys) async {
    try {
      await OneSignal.User.removeTags(tagKeys);
      debugPrint('OneSignal: Tags removed: $tagKeys');
    } catch (e) {
      debugPrint('OneSignal: Failed to remove tags: $e');
      rethrow;
    }
  }

  @override
  // Subscribe to push notifications
  Future<void> subscribeToPushNotifications() async {
    await OneSignal.User.pushSubscription.optIn();
  }

  @override
  // Unsubscribe from push notifications
  Future<void> unsubscribeFromPushNotifications() async {
    await OneSignal.User.pushSubscription.optOut();
  }

  @override
  void handleNotificationNavigation(
    GoRouter router,
    Map<String, dynamic>? data,
  ) {
    if (data == null) {
      debugPrint('Navigation: No data provided for navigation');
      return;
    }

    try {
      // Use the extension method instead of our own implementation
      // router.handleNotificationRoute(data);
    } catch (e) {
      debugPrint('Navigation: Error handling notification navigation: $e');
    }
  }
}
