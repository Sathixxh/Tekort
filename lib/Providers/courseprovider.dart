import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tekort/Models/coursemodel.dart';


class CourseProvider with ChangeNotifier {
  final List<CourseModel> _courses = [];

  List<CourseModel> get courses => _courses;

int totalCourseCount = 0;
int totalCourseStudentCount = 0;

Future<void> fetchCourses() async {
  _courses.clear();
  totalCourseCount = 0;
  totalCourseStudentCount = 0;

  try {
    final snapshot = await FirebaseFirestore.instance.collection('courses').get();

 for (var doc in snapshot.docs) {
  final course = CourseModel.fromMap(doc.id, doc.data());
  _courses.add(course);

  totalCourseCount++;

  // ✅ Cast to int explicitly
  final studentCount = (doc.data()['studentCount'] ?? 0) as int;
  totalCourseStudentCount += studentCount;

}



    notifyListeners();
  } catch (e) {
    print('❌ Error fetching courses: $e');
  }
}



Future<void> addCourse(CourseModel course) async {
  // Step 1: Add document without ID
  final docRef = await FirebaseFirestore.instance.collection('courses').add(course.toMap());

  // Step 2: Create new CourseModel with the generated ID
  final newCourse = CourseModel(
    id: docRef.id, // <-- This is the auto-generated Firestore document ID
    title: course.title,
    subtitle: course.subtitle,
    duration: course.duration,
    description: course.description,
    studentCount: course.studentCount,
  );

  // Step 3: Update Firestore with the ID (optional but helpful)
  await docRef.update({'id': docRef.id});

  // Step 4: Add to local list
  _courses.add(newCourse);

  notifyListeners();
}
Future<void> updateCourse(CourseModel updatedCourse) async {
  try {
    // 1. Update Firestore document
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(updatedCourse.id)
        .update(updatedCourse.toMap());

    // 2. Update local list
    final index = _courses.indexWhere((c) => c.id == updatedCourse.id);
    if (index != -1) {
      _courses[index] = updatedCourse;
      notifyListeners();
    }

  } catch (e) {
    print('❌ Error updating course: $e');
  }
}

Future<void> deleteCourse(String id) async {
  try {
    // 1. Delete from Firestore
    await FirebaseFirestore.instance.collection('courses').doc(id).delete();

    // 2. Delete from local list
    _courses.removeWhere((course) => course.id == id);

    notifyListeners();
  } catch (e) {
    print('❌ Error deleting course: $e');
  }
}

}


