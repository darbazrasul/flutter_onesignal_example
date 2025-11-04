// import 'package:flutter/material.dart';
// import 'package:flutter_onesignal_example/features/repositories/notification_manager.dart';;
// import 'package:shahan_real_estate/features/notifcaton/repositories/notification_manager.dart';

// class NotificationPermissionManager with WidgetsBindingObserver {
//   static const String _permissionRequestedKey =
//       'notification_permission_requested';
//   NotificationPermissionManager() {
//     WidgetsBinding.instance.addObserver(this);
//   }

//   ///********************************** */
//   // Remove this method to stop OneSignal Debugging
//   // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
//   //********************************** */

//   /// Marks that notification permission has been requested
//   Future<void> markPermissionRequested() async {
//     await getIt
//         .get<Prefs>()
//         .saveData(key: _permissionRequestedKey, value: 'true');
//   }

//   /// Checks if notification permission was previously requested
//   Future<bool> wasPermissionRequested() async {
//     return getIt.get<Prefs>().getData(key: _permissionRequestedKey) != null;
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _checkPermissionOnResume();
//     }
//   }

//   /// Checks notification permission when app resumes from background
//   Future<void> _checkPermissionOnResume() async {
//     try {
//       final wasRequested = await wasPermissionRequested();
//       if (wasRequested) {
//         debugPrint('Checking notification permission on app resume');

//         // Try to initialize notification manager
//         // This will re-request permission if needed
//         await NotificationManager()
//             .initialize(getIt.get<Prefs>().getData(key: 'appRouter'));
//       }
//     } catch (e) {
//       debugPrint('Error checking notification permission: $e');
//     }
//   }

//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//   }
// }
