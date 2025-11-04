// import 'package:flutter/material.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:flutter/services.dart';

// class BadgeService {
//   // Get current badge count
//   static Future<int> getBadgeCount() async {
//     try {
//       return await OneSignal.User.pushSubscription.id.then((deviceState) {
//         return deviceState?.badgeCount ?? 0;
//       });
//     } catch (e) {
//       debugPrint('Error getting badge count: $e');
//       return 0;
//     }
//   }

//   // Update badge count (increment)
//   static Future<void> incrementBadgeCount() async {
//     try {
//       int currentCount = await getBadgeCount();
//       await setBadgeCount(currentCount + 1);
//     } catch (e) {
//       debugPrint('Error incrementing badge count: $e');
//     }
//   }

//   // Update badge count (set specific value)
//   static Future<void> setBadgeCount(int count) async {
//     try {
//       // Set OneSignal badge count
//       // await OneSignal.User.sendTag("badge_count", count.toString());
//       await OneSignal.User.
      
//       // Set device badge count
//       if (count > 0) {
//         await OneSignal.shared.setExternalUserId(count.toString());
//       }
      
//       // Platform-specific badge handling
//       await _setPlatformBadge(count);
//     } catch (e) {
//       debugPrint('Error setting badge count: $e');
//     }
//   }

//   // Clear all badges
//   static Future<void> clearBadge() async {
//     try {
//       await setBadgeCount(0);
//     } catch (e) {
//       debugPrint('Error clearing badge: $e');
//     }
//   }

//   // Platform-specific implementation
//   static Future<void> _setPlatformBadge(int count) async {
//     try {
//       // This uses platform channels to set the badge on the app icon
//       const platform = MethodChannel('com.yourapp/badge');
//       await platform.invokeMethod('setBadge', {'count': count});
//     } catch (e) {
//       // Fall back to OneSignal's method if platform channel fails
//       await OneSignal.shared.removeExternalUserId();
//       if (count > 0) {
//         await OneSignal.shared.setExternalUserId(count.toString());
//       }
//     }
//   }
// }



//**************** | aaaaaaa va lbo pashti update badge count | ****************