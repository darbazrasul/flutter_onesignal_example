# Integration Guide - Notification Demo Page

## 📦 Files Created

1. **notification_demo_page.dart** - Complete notification demo UI
2. **main_updated.dart** - Updated main.dart with proper NotificationManager initialization

## 🚀 How to Integrate

### Step 1: Add Demo Page to Your Project

Copy `notification_demo_page.dart` to:
```
lib/features/notification/pages/notification_demo_page.dart
```

Or wherever you keep your pages.

### Step 2: Update Your Router

Add the demo page route to your `AppRouter`:

```dart
// In your app_routers.dart or wherever you define routes

GoRoute(
  path: '/notification-demo',
  name: 'notificationDemo',
  builder: (context, state) => const NotificationDemoPage(),
),
```

### Step 3: Update main.dart

Replace your current main.dart initialization with the code from `main_updated.dart`:

**Key Changes:**
```dart
// OLD - Your current approach
final notificationService = NotificationServiceImpl();
await notificationService.initialize();
await notificationService.requestPermission();
notificationService.setNotificationHandlers(
  onClicked: (event) { /* ... */ },
  onReceived: (event) { /* ... */ },
);

// NEW - Use NotificationManager instead
final notificationManager = NotificationManager();
final isInitialized = await notificationManager.initialize(AppRouter.router);

if (isInitialized) {
  debugPrint('✅ NotificationManager initialized successfully');
  await notificationManager.checkForInitialNotification();
}
```

**Why?** Your `NotificationManager` already wraps the service and handles all the setup internally!

### Step 4: Add Navigation to Demo Page

Add a button in your app to navigate to the demo page:

```dart
// Example: In your settings or debug menu
ElevatedButton(
  onPressed: () {
    context.push('/notification-demo');
  },
  child: const Text('Test Notifications'),
)
```

Or add it to your drawer:

```dart
ListTile(
  leading: const Icon(Icons.notifications_active),
  title: const Text('Notification Demo'),
  onTap: () {
    Navigator.pop(context); // Close drawer
    context.push('/notification-demo');
  },
)
```

## 📱 Using the Demo Page

### Features Available:

1. **Status Card**
   - View Player ID (tap to copy)
   - Check subscription status
   - See platform info

2. **Subscribe/Unsubscribe**
   - Toggle notification subscription
   - Works with your existing NotificationManager

3. **Send Test Notification**
   - Sends a local notification immediately
   - See it appear in the notifications list

4. **User Tags**
   - Add tags: `user_type`, `city`, `language`, `interests`
   - Remove tags
   - Use for targeted notifications in OneSignal dashboard

5. **Notification History**
   - See received notifications in-app
   - Clear individual notifications

## 🧪 Testing Notifications

### Method 1: Local Test (Instant)
1. Open demo page
2. Tap "Send Test Notification"
3. See notification appear immediately

### Method 2: OneSignal Dashboard
1. Open demo page
2. Copy Player ID from status card
3. Go to [OneSignal Dashboard](https://app.onesignal.com)
4. Click Messages > New Push
5. Select "Test Users"
6. Paste your Player ID
7. Fill in title and message
8. Click "Send Message"
9. See notification on your device!

### Method 3: Backend API
Use the Player ID with your backend to send targeted notifications:

```dart
// Example API call
final playerId = await NotificationManager().getPlayerId();

// Send to your backend
await http.post(
  Uri.parse('YOUR_BACKEND_URL/send-notification'),
  body: {
    'playerId': playerId,
    'title': 'Hello',
    'message': 'Test from backend',
  },
);
```

## 🎨 Customization

### Change Colors
```dart
// In notification_demo_page.dart
AppBar(
  backgroundColor: Colors.deepPurple, // Change this
)

// Subscription card color
backgroundColor: _isSubscribed ? Colors.green : Colors.orange, // Change these
```

### Add Custom Tags
```dart
// Modify _addUserTags() method
await _notificationManager.addTags({
  'subscription_plan': 'premium',
  'property_interests': 'apartment',
  'location_preference': 'duhok',
  'language': 'ar',
  // Add your own tags
});
```

### Customize Notification Actions
```dart
// Add to notification data for deep linking
await _notificationManager.showLocalNotification(
  title: 'New Property',
  body: 'Check out this amazing property!',
  payload: {
    'type': 'property_detail',
    'route': '/PropertDetailsView',
    'itemId': 123,
    'projectId': 456,
    'itemPerpose': 'sale',
    'itemType': 'apartment',
  },
);
```

## 📊 Advanced Features

### Track Notification Analytics

Add to your demo page:

```dart
// Track when user opens notifications
void _trackNotificationOpened(Map<String, dynamic> data) {
  // Your analytics service
  Analytics.logEvent('notification_opened', data);
}
```

### Handle Different Notification Types

Your existing router extension already handles:
- `property_detail`
- `project_detail`
- `news_detail`
- `all` (notifications page)

Test these by sending notifications with the appropriate type in the payload!

### iOS-Specific Features

Already implemented in your NotificationManager:
- Badge count management
- Critical notifications
- Background notification handling
- Initial notification check (when app is terminated)

## 🐛 Troubleshooting

### Notifications not showing?
1. Check subscription status in demo page
2. Verify Player ID is not null
3. Check OneSignal App ID in `notification_service.dart` (line 43)
4. Ensure permissions are granted

### Player ID is null?
1. Wait a few seconds after app starts
2. Pull to refresh the demo page
3. Check OneSignal initialization logs in console
4. Restart app

### Tags not working?
1. Verify OneSignal dashboard shows tags
2. Check debug logs for errors
3. Ensure app is subscribed to notifications

## 📝 Important Notes

### Your Architecture
- ✅ `NotificationService` - Low-level OneSignal wrapper
- ✅ `NotificationManager` - High-level manager (use this!)
- ✅ `GoRouterExtension` - Handles navigation from notifications
- ✅ Demo Page - UI for testing everything

### Best Practices
1. Always use `NotificationManager` in your UI code
2. Don't directly use `NotificationService` unless needed
3. Router extension handles all navigation automatically
4. Add tags for user segmentation
5. Test on real devices for best results

## 🔗 Quick Links

- [OneSignal Dashboard](https://app.onesignal.com)
- [OneSignal Docs](https://documentation.onesignal.com/)
- [Flutter OneSignal Plugin](https://pub.dev/packages/onesignal_flutter)

## 🎯 Next Steps

1. ✅ Add demo page to router
2. ✅ Update main.dart
3. ✅ Test local notifications
4. ✅ Test OneSignal dashboard notifications
5. ✅ Add custom tags for your users
6. ✅ Integrate with your backend
7. ✅ Add analytics tracking
8. ✅ Customize UI to match your app theme

---

**That's it! You now have a fully functional notification demo page integrated with your existing architecture!** 🎉

Need help? Check the comments in the code or your existing `NotificationService` documentation.
