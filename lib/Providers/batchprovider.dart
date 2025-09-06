import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tekort/Models/batchmodel.dart';
class BatchProvider with ChangeNotifier {
  List<BatchModel> _batches = []; // all batches
  List<BatchModel> _userBatches = []; // filtered by UID

  List<BatchModel> get batches => _batches;
  List<BatchModel> get userBatches => _userBatches;

  // Fetch all batches
int totalBatchCount = 0;
int totalStudentCount = 0;

Future<void> fetchBatches() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('batches').get();

    _batches = snapshot.docs
        .map((doc) => BatchModel.fromJson(doc.data(), doc.id))
        .toList();

    totalBatchCount = _batches.length;

    // Count students in each batch
    totalStudentCount = 0;
    for (var batch in _batches) {
      if (batch.studentmap is List) {
        totalStudentCount += (batch.studentmap as List).length;
      } else if (batch.studentmap is Map) {
        totalStudentCount += (batch.studentmap as Map).length;
      }
    }



    notifyListeners();
  } catch (e) {
    print("❌ Error fetching batches: $e");
  }
}


  // ✅ Fetch user-specific batches (filtered by UID)
Future<void> fetchBatchesByUID(String uid) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('batches')
      .where('uid', isEqualTo: uid)
      .get();

  _userBatches = snapshot.docs
      .map((doc) => BatchModel.fromJson(doc.data(), doc.id))
      .toList();


  notifyListeners();
}




  Future<void> addOrUpdateBatch(BatchModel batch) async {
    final batchRef = FirebaseFirestore.instance.collection('batches').doc(
          batch.id.isNotEmpty ? batch.id : null,
        );

    final data = batch.toJson();

    if (batch.id.isNotEmpty) {
      await batchRef.update(data);
    } else {
      await FirebaseFirestore.instance.collection('batches').add(data);
    }

    await fetchBatches(); // refresh full list after update
  }
}



