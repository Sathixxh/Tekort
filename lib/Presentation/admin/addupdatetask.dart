

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tekort/core/core/common/loading.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
class TaskScreennew extends StatefulWidget {
  @override
  _TaskScreennewState createState() => _TaskScreennewState();
}

class _TaskScreennewState extends State<TaskScreennew> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  Color get primaryColor => Theme.of(context).primaryColor;
  Color get backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get cardColor => Theme.of(context).cardColor;
  Color get textColor => Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  Color get surfaceColor => Theme.of(context).colorScheme.surface;
  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
      _initAnimations();
      }
  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
   void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
   ;
    super.dispose();
  }

  void _openTaskBottomSheet() {
    final nameController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    String? selectedBatchId;
    String? selectedBatchName;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 24,
            right: 24,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 60,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 25),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Title with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.task_alt, color: primaryColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Create New Task',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Task Name Field
                _buildAnimatedTextField(
                  controller: nameController,
                  label: 'Task Name',
                  icon: Icons.assignment,
                  delay: 100,
                ),
                const SizedBox(height: 20),

                // Start Date Field
                _buildAnimatedTextField(
                  controller: startDateController,
                  label: 'Start Date',
                  icon: Icons.calendar_today,
                  readOnly: true,
                  delay: 200,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: primaryColor,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      startDate = picked;
                      startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                ),
                const SizedBox(height: 20),

                // End Date Field
                _buildAnimatedTextField(
                  controller: endDateController,
                  label: 'End Date',
                  icon: Icons.event,
                  readOnly: true,
                  delay: 300,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: primaryColor,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      endDate = picked;
                      endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Batch Dropdown
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 900),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('batches')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: surfaceColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child:loadingWidget()
                                );
                              }

                              final docs = snapshot.data!.docs;
                              return DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Select Batch',
                                  labelStyle: TextStyle(color: primaryColor),
                                  prefixIcon: Icon(Icons.group, color: primaryColor),
                                  filled: true,
                                  fillColor: surfaceColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: primaryColor, width: 2),
                                  ),
                                ),
                                dropdownColor: cardColor,
                                items: docs.map((doc) {
                                  final batchCode = doc['batchCode'] ?? doc.id;
                                  return DropdownMenuItem<String>(
                                    value: doc.id,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            batchCode.substring(0, 1).toUpperCase(),
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(batchCode, style: TextStyle(color: textColor)),
                                      ],
                                    ),
                                    onTap: () {
                                      selectedBatchName = batchCode;
                                    },
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  selectedBatchId = val;
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Submit Button
                _buildAnimatedButton(
                  text: 'Create Task',
                  icon: Icons.add_task,
                  onPressed: () => _handleTaskSubmit(
                    nameController,
                    startDate,
                    endDate,
                    selectedBatchId,
                    selectedBatchName,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    int delay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              
              ),
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                onTap: onTap,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(color: primaryColor),
                  prefixIcon: Icon(icon, color: primaryColor),
                  suffixIcon: readOnly ? Icon(Icons.calendar_today, color: primaryColor) : null,
                  
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: Colors.white),
              label: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }




Future<void> sendPushMessage(String targetToken, String title, String body) async {
 
  try {
    // Load service account
    final serviceAccountJson = await rootBundle.loadString('assets/firsbasetoken/emaillink-c3ec5-firebase-adminsdk-7jtui-c7c7f48b27.json');
    final serviceAccount = ServiceAccountCredentials.fromJson(json.decode(serviceAccountJson));

    // Auth scope for FCM
    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    // Create authenticated HTTP client
    final client = await clientViaServiceAccount(serviceAccount, scopes);

    final projectId = json.decode(serviceAccountJson)['project_id'];
    final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

    final message = {
      "message": {
        "token": targetToken,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
        }
      }
    };

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(message),
    );

  
    client.close();
  } catch (e) {
    print("Error sending push notification: $e");
  }
}



  
Future<void> _handleTaskSubmit(
  TextEditingController nameController,
  DateTime? startDate,
  DateTime? endDate,
  String? selectedBatchId,
  String? selectedBatchName,
) async {
  if (nameController.text.isEmpty ||
      startDate == null ||
      endDate == null ||
      selectedBatchId == null ||
      selectedBatchName == null) {
    _showSnackBar('Please fill all fields.', Colors.orange);
    return;
  }

  if (endDate.isBefore(startDate)) {
    _showSnackBar('End date must be after start date.', Colors.orange);
    return;
  }

  try {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: loadingWidget(),
        ),
      ),
    );

    // Fetch batch data
    final batchDoc = await FirebaseFirestore.instance
        .collection('batches')
        .doc(selectedBatchId)
        .get();

    final originalStudentMap =
        batchDoc.data()?['studentmap'] as Map<String, dynamic>?;
    final Map<String, dynamic> taskStudentMap = {};

    List<String> studentUids = [];

    if (originalStudentMap != null) {
      originalStudentMap.forEach((uid, studentData) {
        final studentName = studentData['name'];
        if (studentName != null) {
          taskStudentMap[studentName] = {
            'studentname': studentName,
            'taskName': nameController.text.trim(),
            'status': 'Pending',
            'uid': uid,
            'startDate': startDate.toIso8601String(),
            'endDate': endDate.toIso8601String(),
          };
          studentUids.add(uid); // Collect UIDs for notification
        }
      });
    }

    // Create the task document
    final taskRef =
        await FirebaseFirestore.instance.collection('tasks').add({
      'taskName': nameController.text.trim(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'batchId': selectedBatchId,
      'batchName': selectedBatchName,
      'createdAt': FieldValue.serverTimestamp(),
      'studentMap': taskStudentMap,
    });

    // Fetch tokens for each UID and send notification
    for (String uid in studentUids) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final fcmToken = userDoc.data()?['fcmToken'];
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await sendPushMessage(
          fcmToken,
          "New Task Assigned",
          "${nameController.text.trim()} from $selectedBatchName",
        );
      }
    }

    Navigator.pop(context); // Close loading dialog
    Navigator.pop(context); // Close bottom sheet
    _showSnackBar('Task created successfully!', Colors.green);
  } catch (e) {
    Navigator.pop(context); // Close loading dialog
    Navigator.pop(context); // Close bottom sheet
    _showSnackBar('Failed to create task.', Colors.red);
  }
}

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildTaskCard(DocumentSnapshot task, int index) {
    final taskName = task['taskName'] ?? '';
    final startDate = task['startDate'];
    final endDate = task['endDate'];
    final batchName = task['batchName'] ?? 'Unknown Batch';
    final Map<String, dynamic> studentMap = Map<String, dynamic>.from(task['studentMap'] ?? {});

    // Calculate progress
    final totalStudents = studentMap.length;
    final completedStudents = studentMap.values.where((student) => student['status'] == 'Completed').length;
    final progress = totalStudents > 0 ? completedStudents / totalStudents : 0.0;

    return AnimatedContainer(
        duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
            // color: primaryColor,
          elevation: 5,
          child: Container(
            // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                  //  color: primaryColor,
                   
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
            //     BoxShadow(
            //   color: primaryColor.withOpacity(0.1),
            //   blurRadius: 2,
            //   offset:Offset.zero
            // ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.assignment, color: primaryColor, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              taskName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                batchName,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _confirmDeleteTask(task.id, studentMap),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
          
                  // Date range
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: primaryColor, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
          
                  // Progress section
                  Row(
                    children: [
                      Icon(Icons.people, color: primaryColor, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Progress: $completedStudents/$totalStudents completed',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Progress bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: progress == 1.0 ? Colors.green : primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
          
                  // Students list
                  if (studentMap.isNotEmpty) ...[
                    Text(
                      'Students:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...studentMap.entries.map((entry) {
                      final studentUid = entry.key;
                      final studentDetails = Map<String, dynamic>.from(entry.value);
                      final studentStatus = studentDetails['status'] ?? 'Pending';
                      final studentName = studentDetails['studentname'] ?? 'Student';
                      final studentuuid2 = studentDetails['uid'] ?? 'uid';
          
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: studentStatus == 'Completed' 
                                ? Colors.green.withOpacity(0.3) 
                                : primaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: studentStatus == 'Completed' ? Colors.green : Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                studentName,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: studentStatus == 'Completed' 
                                    ? Colors.green.withOpacity(0.1) 
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: studentStatus,
                                  isDense: true,
                                  dropdownColor: cardColor,
                                  items: ['Pending', 'Completed']
                                      .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(
                                              status,
                                              style: TextStyle(
                                                color: status == 'Completed' 
                                                    ? Colors.green 
                                                    : Colors.orange,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (newStatus) {
                                    if (newStatus != null) {

                                      
                                      _updateStudentTaskStatus(
                                        task.id,
                                        studentUid,
                                        newStatus,
                                        studentuuid2,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTask(String taskId, Map<String, dynamic> studentMap) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: cardColor,
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text('Delete Task', style: TextStyle(color: textColor)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: primaryColor)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteTask(taskId, studentMap);
    }
  }

Future<void> _updateStudentTaskStatus(
  String taskId,
  String studentUid, // This is the key in studentMap
  String newStatus,
  String studentuuid2, // This is the UID of the student in "users" collection
) async {
  final taskRef = FirebaseFirestore.instance.collection('tasks').doc(taskId);
  final userDocRef2 = FirebaseFirestore.instance.collection('users').doc(studentuuid2);

  try {
    final taskSnapshot = await taskRef.get();
    final taskData = taskSnapshot.data();
    if (taskData == null) return;

    final studentMap = Map<String, dynamic>.from(taskData['studentMap'] ?? {});
    if (studentMap.containsKey(studentUid)) {
      studentMap[studentUid]['status'] = newStatus;
      await taskRef.update({'studentMap': studentMap});
    }

    // 🔹 Fetch FCM token for that student
    final userDoc = await userDocRef2.get();
    final fcmToken = userDoc.data()?['fcmToken'];

    // 🔹 Send push notification if token exists
    if (fcmToken != null && fcmToken.isNotEmpty) {
      final taskName = taskData['taskName'] ?? 'Task';
      await sendPushMessage(
        fcmToken,
        "Task Status Updated",
        "Your task '$taskName' has been marked as $newStatus.",
      );
    }

    _showSnackBar(
      'Status updated successfully!',
      newStatus == 'Completed' ? Colors.green : Colors.orange,
    );
  } catch (e) {
    _showSnackBar('Failed to update status.', Colors.red);
    print("Error updating task status: $e");
  }
}



  Future<void> _deleteTask(String taskId, Map<String, dynamic> studentMap) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child:loadingWidget()
          ),
        ),
      );

      // Delete the task from the "tasks" collection
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();

      // Remove the task entry from each user's taskMap
      for (var key in studentMap.keys) {
        final studentData = studentMap[key];
        final uid = studentData['uid'];

        if (uid != null) {
          final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
          final userDoc = await userRef.get();

          if (userDoc.exists) {
            final userData = userDoc.data() ?? {};
            final taskMap = Map<String, dynamic>.from(userData['taskMap'] ?? {});
            
            if (taskMap['taskId'] == taskId) {
              await userRef.update({'taskMap': FieldValue.delete()});
            }
          }
        }
      }

      Navigator.pop(context); // Close loading dialog
      _showSnackBar('Task deleted successfully!', Colors.green);
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showSnackBar('Failed to delete task.', Colors.red);
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'N/A';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          children: [
           
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tasks')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: loadingWidget()
                        );
                      }
        
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.assignment_outlined,
                                  size: 80,
                                  color: primaryColor.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No tasks yet',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textColor.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your first task to get started',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textColor.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
        
                      final tasks = snapshot.data!.docs;
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 16, bottom: 100),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          return _buildTaskCard(tasks[index], index);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: ScaleTransition(
          scale: _scaleAnimation,
          child: FloatingActionButton(
            onPressed: _openTaskBottomSheet,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}