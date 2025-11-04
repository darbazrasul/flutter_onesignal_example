# Testing Checklist ✅

Use this checklist to verify your OneSignal notification integration is working correctly.

## 🚀 Initial Setup

- [ ] Added `notification_demo_page.dart` to your project
- [ ] Updated `main.dart` with NotificationManager initialization
- [ ] Added route to `app_routers.dart`
- [ ] Added navigation button/menu item to access demo page
- [ ] Ran `flutter pub get`
- [ ] OneSignal App ID is correct in `notification_service.dart`
- [ ] `google-services.json` (Android) is in place
- [ ] Built and ran the app

## 📱 Basic Functionality

### Initialization
- [ ] App starts without errors
- [ ] Console shows: "✅ NotificationManager initialized successfully"
- [ ] Console shows OneSignal Player ID
- [ ] No error messages in console

### Demo Page Access
- [ ] Can navigate to notification demo page
- [ ] Page loads without errors
- [ ] UI displays correctly
- [ ] Status card shows information

## 🔔 Notification Features

### Status Card
- [ ] Player ID is displayed (not null)
- [ ] Can copy Player ID (tap on it)
- [ ] Subscription status shows correctly
- [ ] Platform (Android/iOS) displays correctly
- [ ] Pull to refresh updates the status

### Subscribe/Unsubscribe
- [ ] Toggle switch works
- [ ] Status changes when toggled
- [ ] SnackBar shows success message
- [ ] Console logs subscription change

### Local Notifications
- [ ] "Send Test Notification" button works
- [ ] Local notification appears on device
- [ ] Notification shows in system tray
- [ ] Can tap notification to open app
- [ ] Notification appears in demo page history
- [ ] Can clear individual notifications

### User Tags
- [ ] "Add Tags" button works
- [ ] Success message appears
- [ ] Console shows tags added
- [ ] "Remove Tags" button works
- [ ] Tags appear in OneSignal dashboard (check User > Tags)

## 🌐 OneSignal Dashboard Tests

### Preparation
- [ ] Logged into OneSignal dashboard
- [ ] Found your app
- [ ] Copied Player ID from demo page

### Send Test Notification
- [ ] Went to Messages > New Push
- [ ] Selected "Test Users"
- [ ] Pasted Player ID
- [ ] Entered title: "Test from Dashboard"
- [ ] Entered message: "This is a test notification"
- [ ] Clicked "Send Message"
- [ ] Notification appeared on device
- [ ] Notification works when app is:
  - [ ] In foreground (open)
  - [ ] In background (minimized)
  - [ ] Terminated (closed)

### Send to All Users
- [ ] Created new notification
- [ ] Selected "All Users" segment
- [ ] Sent notification
- [ ] Received notification on device

### Send with Additional Data
- [ ] Created notification with additional data:
  ```json
  {
    "type": "property_detail",
    "route": "/PropertDetailsView",
    "itemId": "123",
    "fromNotification": true
  }
  ```
- [ ] Notification received
- [ ] Tapping notification navigates correctly
- [ ] Console shows navigation data

## 📊 Navigation Tests

### Property Detail Navigation
Test notification with:
```json
{
  "type": "property_detail",
  "route": "/PropertDetailsView",
  "itemId": "123",
  "projectId": "456",
  "itemPerpose": "sale",
  "itemType": "apartment",
  "fromNotification": true
}
```
- [ ] Navigates to navbar first
- [ ] Then navigates to property detail
- [ ] All data is passed correctly

### Project Detail Navigation
Test notification with:
```json
{
  "type": "project_detail",
  "route": "/projectView",
  "projectId": "789",
  "fromNotification": true
}
```
- [ ] Navigates to navbar first
- [ ] Then navigates to project detail
- [ ] Project ID is passed correctly

### News Detail Navigation
Test notification with:
```json
{
  "type": "news_detail",
  "route": "/article/123",
  "newsId": "123",
  "fromNotification": true
}
```
- [ ] Navigates to navbar first
- [ ] Then navigates to news detail
- [ ] News ID is passed correctly

### Notifications Page Navigation
Test notification with:
```json
{
  "type": "all",
  "route": "/notifications",
  "fromNotification": true
}
```
- [ ] Navigates to navbar first
- [ ] Then opens notifications page
- [ ] Type parameter is passed

## 🍎 iOS-Specific Tests (if applicable)

### Initial Setup
- [ ] Push Notifications capability enabled in Xcode
- [ ] Background Modes > Remote notifications enabled
- [ ] APNs certificate/key configured in OneSignal

### Functionality
- [ ] Notification permission requested
- [ ] Permission dialog shows correctly
- [ ] Badge count updates
- [ ] Notifications work when app is terminated
- [ ] `checkForInitialNotification()` works

### Badge Management
- [ ] Badge count increases with notifications
- [ ] Badge count can be reset
- [ ] Badge count shows correctly on app icon

## 🤖 Android-Specific Tests

### Initial Setup
- [ ] `google-services.json` in correct location
- [ ] Notification permission requested (Android 13+)
- [ ] Permission granted

### Functionality
- [ ] Notification channel created
- [ ] High importance notifications work
- [ ] Notification sounds play
- [ ] Heads-up notifications display

## 🔍 Debug & Console Logs

### Expected Logs on App Start
```
✅ NotificationManager initialized successfully
OneSignal: Starting initialization...
OneSignal: Initial Player ID: [player-id]
Local Notifications: Initialization complete
```

### Expected Logs on Notification Received (Foreground)
```
OneSignal: Notification received in foreground:
Title: [notification title]
Body: [notification body]
Data: [additional data]
Local Notification: Displayed from OneSignal notification
```

### Expected Logs on Notification Clicked
```
NotificationManager: Notification clicked
OneSignal: Notification clicked:
Title: [notification title]
Data: [additional data]
Navigation: Handling route=[route], type=[type]
```

## 🚨 Common Issues Checklist

### Player ID is null
- [ ] Waited 5-10 seconds after app start
- [ ] Refreshed the demo page
- [ ] Checked OneSignal App ID is correct
- [ ] Checked internet connection
- [ ] Restarted app
- [ ] Checked console for initialization errors

### Notifications not showing
- [ ] Verified subscription status is "Subscribed"
- [ ] Checked notification permissions are granted
- [ ] Confirmed Player ID is valid
- [ ] Checked OneSignal dashboard delivery status
- [ ] Verified app is not in Do Not Disturb mode
- [ ] Tested on physical device (not emulator)

### Notifications showing but not navigating
- [ ] Checked additional data is present
- [ ] Verified route format is correct
- [ ] Console shows navigation logs
- [ ] GoRouter extension is imported
- [ ] Routes are defined in router
- [ ] `fromNotification: true` is set

### Tags not working
- [ ] Checked console for tag errors
- [ ] Verified in OneSignal dashboard (Users > select user > Tags)
- [ ] Ensured user is subscribed
- [ ] Player ID is valid

## 📈 Performance Tests

- [ ] App starts quickly (no delays from notifications)
- [ ] No memory leaks from notification listeners
- [ ] Notification response is immediate
- [ ] Multiple notifications handled correctly
- [ ] No crashes when sending many notifications

## 🎯 Production Readiness

- [ ] Remove debug logging (OSLogLevel.verbose) before release
- [ ] Test on multiple devices
- [ ] Test on different Android versions
- [ ] Test on different iOS versions
- [ ] Verify notification appearance on light/dark mode
- [ ] Test notification sounds
- [ ] Test notification images (if using)
- [ ] Test scheduled notifications (if using)
- [ ] Load test with multiple concurrent notifications
- [ ] Verify analytics/tracking (if implemented)

## 📝 Documentation

- [ ] Team knows how to send notifications
- [ ] Backend integration documented
- [ ] Notification payload format documented
- [ ] Navigation routes documented
- [ ] Tag structure documented

## ✅ Final Verification

### Critical Path Test
1. [ ] Fresh install of app
2. [ ] Permission granted
3. [ ] Player ID obtained
4. [ ] Sent notification from dashboard
5. [ ] Notification received
6. [ ] Tapped notification
7. [ ] Navigated to correct screen
8. [ ] All data passed correctly

### Edge Cases
- [ ] Notification when app is installing
- [ ] Notification when battery is low
- [ ] Notification when in airplane mode (shouldn't crash)
- [ ] Notification with malformed data (graceful handling)
- [ ] Notification with missing required fields

## 🎉 Success Criteria

Your integration is successful when:
- ✅ All basic functionality works
- ✅ All OneSignal dashboard tests pass
- ✅ All navigation tests work correctly
- ✅ No errors in console
- ✅ Works on both Android and iOS
- ✅ Works in all app states (foreground, background, terminated)

---

## 📊 Test Report Template

```
Date: _______________
Tester: _______________
Device: _______________
OS Version: _______________

✅ Passed Tests: ___ / 100
❌ Failed Tests: ___
⚠️  Issues Found: ___

Notes:
_________________________________
_________________________________
_________________________________

Critical Issues:
_________________________________
_________________________________
_________________________________

Next Steps:
_________________________________
_________________________________
_________________________________
```

---

**Once all items are checked, your notification system is production-ready!** 🚀

Need help? Review the INTEGRATION_GUIDE.md or check console logs for specific errors.
