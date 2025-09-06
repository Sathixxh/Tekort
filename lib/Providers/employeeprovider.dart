import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeProvider with ChangeNotifier {
  String? name, email, course, customId, password, phoneno;
  
  Map<String, dynamic>? taskMap;
  List<Map<String, dynamic>> taskList = []; // ✅ New: List of tasks for UI

  bool isLoading = false;
  List<Map<String, dynamic>> allUsers = [];

  // Add these role count variables
  int employeeCount = 0;
  int adminCount = 0;
  int totalCount = 0;

  /// ✅ Fetch current employee's details and parse taskMap.* keys into a list
  Future<void> fetchEmployeeDetails() async {
    isLoading = true;
    notifyListeners();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (snapshot.exists) {
          final data = snapshot.data()!;
          name = data['name'];
          email = data['email'];
          course = data['course'];
          customId = data['customId'];
          password = data['password'];
          phoneno = data['phone'];

          // ✅ Reset taskList
          taskList = [];

          // ✅ Extract all taskMap.<taskId> entries
          data.forEach((key, value) {
            if (key.startsWith('taskMap.')) {
              final taskId = key.split('.')[1];
              final taskData = Map<String, dynamic>.from(value);
              taskList.add({
                'taskId': taskId,
                ...taskData,
              });
            }
          });

        }
      }
    } catch (e) {
      print("Error fetching employee details: $e");
    }

    isLoading = false;
    notifyListeners();
  }
Future<void> fetchAllUsers() async {
  isLoading = true;
  notifyListeners();

  try {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    employeeCount = 0;
    adminCount = 0;

    allUsers = querySnapshot.docs.map((doc) {
      final data = doc.data();

      final role = data['role'] ?? 'employee';
      if (role == 'admin') {
        adminCount++;
      } else {
        employeeCount++;
      }

      // Keep original mapping if needed
      return {
        'id': doc.id,
        ...data, // ✅ includes all fields from Firestore automatically
      };
    }).toList();

    totalCount = allUsers.length;

  } catch (e) {
    print("Error fetching all users: $e");
  }

  isLoading = false;
  notifyListeners();
}

}
