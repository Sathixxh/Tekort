// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tekort/Presentation/notification/notificationmodel.dart';


// class NotificationProvider extends ChangeNotifier {
//   List<NotificationModel> _notifications = [];

//   List<NotificationModel> get notifications => _notifications;

//   NotificationProvider() {
//     loadNotifications();
//   }

//   /// Add a new notification to the list and save it
//   Future<void> addNotification(NotificationModel notification) async {
//     _notifications.insert(0, notification); // Insert at top
//     notifyListeners();
//     await saveNotifications();
//   }

//   /// Save all notifications to local storage
//   Future<void> saveNotifications() async {
//     final prefs = await SharedPreferences.getInstance();
//     final encodedList =
//         _notifications.map((n) => jsonEncode(n.toMap())).toList();
//     await prefs.setStringList('notifications', encodedList);
//   }

//   /// Load saved notifications from local storage
//   Future<void> loadNotifications() async {
//     final prefs = await SharedPreferences.getInstance();
//     final encodedList = prefs.getStringList('notifications');
//     if (encodedList != null) {
//       _notifications = encodedList
//           .map((e) => NotificationModel.fromMap(jsonDecode(e)))
//           .toList();
//       notifyListeners();
//     }
//   }

//   /// Clear all notifications
//   Future<void> clearNotifications() async {
//     _notifications.clear();
//     notifyListeners();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('notifications');
//   }
// }
