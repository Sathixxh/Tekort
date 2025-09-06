// class NotificationModel {
//   final String title;
//   final String body;
//   final DateTime timestamp;

//   NotificationModel({
//     required this.title,
//     required this.body,
//     required this.timestamp,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'body': body,
//       'timestamp': timestamp.toIso8601String(),
//     };
//   }

//   factory NotificationModel.fromMap(Map<String, dynamic> map) {
//     return NotificationModel(
//       title: map['title'] ?? '',
//       body: map['body'] ?? '',
//       timestamp: DateTime.parse(map['timestamp']),
//     );
//   }
// }
