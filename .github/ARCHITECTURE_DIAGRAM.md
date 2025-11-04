# Architecture Diagram 🏗️

## Your Existing Architecture + New Demo Page

```
┌──────────────────────────────────────────────────────────────┐
│                        Your App                               │
├──────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Firebase Cloud Messaging                │    │
│  │                  (google-services.json)              │    │
│  └─────────────┬───────────────────────────────────────┘    │
│                │                                               │
│                ↓                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                    OneSignal                         │    │
│  │            (82776dd3-cb77-4c69...)                   │    │
│  └─────────────┬───────────────────────────────────────┘    │
│                │                                               │
│                ↓                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │          NotificationService (EXISTING)             │    │
│  │  • initialize()                                      │    │
│  │  • requestPermission()                               │    │
│  │  • setNotificationHandlers()                         │    │
│  │  • getPlayerId()                                     │    │
│  │  • addTags() / removeTags()                         │    │
│  │  • subscribe() / unsubscribe()                       │    │
│  │  • handleNotificationNavigation()                    │    │
│  └─────────────┬───────────────────────────────────────┘    │
│                │                                               │
│                ↓                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │         NotificationManager (EXISTING)              │    │
│  │  Wraps NotificationService with high-level API      │    │
│  │  • initialize(router)                                │    │
│  │  • checkForInitialNotification() [iOS]              │    │
│  │  • getPlayerId()                                     │    │
│  │  • addTags() / removeTags()                         │    │
│  │  • subscribeNotication()                            │    │
│  │  • unsubscribeNotifcation()                         │    │
│  │  • showLocalNotification()                          │    │
│  └─────────────┬───────────────────────────────────────┘    │
│                │                                               │
│                ↓                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │      NotificationDemoPage (NEW! 🎉)                 │    │
│  │  Beautiful UI for testing notifications             │    │
│  │  • Status Dashboard                                  │    │
│  │  • Subscribe/Unsubscribe Toggle                     │    │
│  │  • Send Test Notifications                          │    │
│  │  • Tag Management                                    │    │
│  │  • Notification History                             │    │
│  │  • Testing Instructions                             │    │
│  └─────────────┬───────────────────────────────────────┘    │
│                │                                               │
│                ↓                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │         GoRouterExtension (EXISTING)                │    │
│  │  handleNotificationRoute()                           │    │
│  │  • property_detail → PropertyDetailView             │    │
│  │  • project_detail → ProjectView                     │    │
│  │  • news_detail → NewsView                           │    │
│  │  • all → NotificationsPage                          │    │
│  └─────────────┬───────────────────────────────────────┘    │
│                │                                               │
│                ↓                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Your App Pages                          │    │
│  │  • PropertyDetailView                                │    │
│  │  • ProjectView                                       │    │
│  │  • NewsView                                          │    │
│  │  • NotificationsPage                                │    │
│  │  • ... other pages                                   │    │
│  └──────────────────────────────────────────────────────┘    │
│                                                                │
└──────────────────────────────────────────────────────────────┘
```

## Notification Flow Diagram

### 1. Push Notification Received

```
OneSignal Server
      │
      │ Push Notification
      ↓
Your Device (FCM)
      │
      ↓
NotificationService
      │
      │ Handles notification
      ↓
┌─────────────┐
│ App State?  │
└─────┬───────┘
      │
      ├──→ Foreground → Show local notification
      │                        ↓
      ├──→ Background  → Show system notification
      │                        ↓
      └──→ Terminated  → Show system notification
                              ↓
                        User taps notification
                              ↓
                    NotificationClickHandler
                              ↓
                    GoRouterExtension.handleNotificationRoute()
                              ↓
                    ┌─────────────────┐
                    │  Parse payload  │
                    │  • type         │
                    │  • route        │
                    │  • data         │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
    type=                type=              type=
    property_detail    project_detail    news_detail
        │                    │                    │
        ↓                    ↓                    ↓
    PropertyView         ProjectView          NewsView
```

### 2. Test Notification Flow (Demo Page)

```
NotificationDemoPage
      │
      │ User taps "Send Test Notification"
      ↓
NotificationManager.showLocalNotification()
      │
      ↓
FlutterLocalNotificationsPlugin
      │
      │ Display notification
      ↓
System Notification Tray
      │
      │ User taps
      ↓
NotificationResponse
      │
      ↓
onLocalClicked handler
      │
      ↓
Parse payload & navigate
```

### 3. Tag Management Flow

```
NotificationDemoPage
      │
      │ User taps "Add Tags"
      ↓
NotificationManager.addTags({
  'user_type': 'premium',
  'city': 'Duhok',
  ...
})
      │
      ↓
NotificationService.addTags()
      │
      ↓
OneSignal.User.addTags()
      │
      ↓
OneSignal Server
      │
      │ Updates user profile
      ↓
OneSignal Dashboard
  (User → Tags)
      │
      │ Can now send targeted notifications
      ↓
Send notification to users with tag:
  "city = Duhok"
```

## Integration Points

### Where Your Code Meets Our Code

```
┌──────────────────────────────────────────────────────────────┐
│                     main.dart                                 │
│                                                                │
│  OLD Approach:                                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ final notificationService = NotificationServiceImpl();│   │
│  │ await notificationService.initialize();              │   │
│  │ await notificationService.requestPermission();        │   │
│  │ notificationService.setNotificationHandlers(...);    │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                                │
│  NEW Approach (Recommended):                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ final notificationManager = NotificationManager();   │   │
│  │ await notificationManager.initialize(router);        │   │
│  │ await notificationManager.checkForInitialNotification(); │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                   app_routers.dart                            │
│                                                                │
│  ADD:                                                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ GoRoute(                                              │   │
│  │   path: '/notification-demo',                        │   │
│  │   name: 'notificationDemo',                          │   │
│  │   builder: (context, state) =>                       │   │
│  │       const NotificationDemoPage(),                  │   │
│  │ )                                                     │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                Your UI (Settings/Menu)                        │
│                                                                │
│  ADD Navigation Button:                                       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ ElevatedButton(                                       │   │
│  │   onPressed: () {                                     │   │
│  │     context.push('/notification-demo');              │   │
│  │   },                                                  │   │
│  │   child: Text('Test Notifications'),                 │   │
│  │ )                                                     │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

## File Structure

```
your_app/
├── lib/
│   ├── features/
│   │   ├── notification/
│   │   │   ├── pages/
│   │   │   │   └── notification_demo_page.dart      ← ADD THIS
│   │   │   ├── repositories/
│   │   │   │   ├── go_router_extension.dart        ← EXISTING
│   │   │   │   └── notification_manager.dart       ← EXISTING
│   │   │   └── service/
│   │   │       └── notification_service.dart       ← EXISTING
│   │   │
│   │   ├── property/
│   │   ├── project/
│   │   └── news/
│   │
│   ├── core/
│   │   └── router/
│   │       └── app_routers.dart                    ← UPDATE THIS
│   │
│   └── main.dart                                   ← UPDATE THIS
│
└── android/
    └── app/
        └── google-services.json                     ← EXISTING
```

## Data Flow Example

### Example: Property Notification

```
1. Backend/OneSignal sends notification:
   {
     "title": "New Property in Duhok!",
     "body": "Check out this amazing apartment",
     "data": {
       "type": "property_detail",
       "route": "/PropertDetailsView",
       "itemId": "123",
       "projectId": "456",
       "itemPerpose": "sale",
       "itemType": "apartment",
       "fromNotification": true
     }
   }

2. OneSignal delivers to device
   ↓
3. NotificationService receives
   ↓
4. Shows notification (foreground/background)
   ↓
5. User taps notification
   ↓
6. NotificationClickHandler triggered
   ↓
7. GoRouterExtension.handleNotificationRoute() called
   ↓
8. Checks type = "property_detail"
   ↓
9. _navigateToPropertyDetail() called
   ↓
10. First: router.go(AppRoutes.navbar)
   ↓
11. Then (300ms delay): router.push('/PropertDetailsView', extra: {...})
   ↓
12. PropertyDetailView opens with data
   ↓
13. User sees property details!
```

## Component Responsibility

```
┌─────────────────────────────────────────────────────────────┐
│ Component                │ Responsibility                    │
├──────────────────────────┼───────────────────────────────────┤
│ Firebase                 │ Message delivery (Android)        │
│ OneSignal                │ Push notification service         │
│ NotificationService      │ OneSignal SDK wrapper             │
│ NotificationManager      │ High-level API (USE THIS!)        │
│ GoRouterExtension        │ Parse & route notifications       │
│ NotificationDemoPage     │ Testing UI (NEW!)                 │
│ Your App Pages           │ Display content                   │
└──────────────────────────┴───────────────────────────────────┘
```

## What You Need to Know

### ✅ Already Working (Your Code)
- Firebase integration
- OneSignal setup
- NotificationService
- NotificationManager
- GoRouterExtension
- All your app pages

### ⭐ What We Added (New)
- NotificationDemoPage UI
- Integration examples
- Documentation
- Testing checklist

### 🔧 What You Need to Do
1. Add NotificationDemoPage to your project
2. Add route to router
3. Update main.dart to use NotificationManager
4. Add navigation button
5. Test!

---

**Simple, right?** 🎉

All the hard work is done. Just plug it in and test!

For detailed steps, see: `INTEGRATION_GUIDE.md`
