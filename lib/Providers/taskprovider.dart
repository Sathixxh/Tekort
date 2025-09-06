

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tekort/Models/taskmodel.dart';

// class TaskProvider extends ChangeNotifier {
//   List<TaskModel> _tasks = [];
//   List<TaskModel> get tasks => _tasks;

//   Future<void> fetchTasks() async {
//     print("mmmmmmmmmmmmmmmmmmm");
//     final snapshot = await FirebaseFirestore.instance.collection('tasks').get();
//     _tasks = snapshot.docs.map((doc) {
//       final data = doc.data();
//       print("jjjjjjjjjjjjjjjjjjj${data['taskName']}");
//       //  jjjjjjjjjjjjjjjjjjj{batchName: Tek-001, createdAt: Timestamp(seconds=1753452692, nanoseconds=209000000), endDate: 2025-07-31T00:00:00.000, studentMap: {sat: {uid: scJIo3H0F3aDaVoYR60X1GIyY2O2, studentname: sat, taskName: Task-001, status: Pending}}, taskName: Task-001, batchId: zVrzIRnaZGzAEIIsxsb9, startDate: 2025-07-25T00:00:00.000}
//       return TaskModel(
//         name: data['taskName'],
//         startDate: DateTime.parse(data['startDate']),
//         endDate: DateTime.parse(data['endDate']),
//         status: data['batchName'],
//         batchId: data['batchId'],
//         assignedUsers: List<String>.from(data['assignedUsers']),
//       );
//     }).toList();
//     notifyListeners();
//   }

// }