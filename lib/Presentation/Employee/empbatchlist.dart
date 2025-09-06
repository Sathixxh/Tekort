
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tekort/Models/batchmodel.dart';
import 'package:tekort/core/core/common/loading.dart';

class UserBatchList extends StatefulWidget {
  final String uid;
  const UserBatchList({super.key, required this.uid});

  @override
  State<UserBatchList> createState() => _UserBatchListState();
}

class _UserBatchListState extends State<UserBatchList> {
  List<BatchModel> userBatches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserBatches(widget.uid);
  }
  Future<void> fetchUserBatches(String uid) async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('batches').get();

      List<BatchModel> allBatches = snapshot.docs.map((doc) {
        return BatchModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Filter batches where uid is a key inside studentmap
      List<BatchModel> filtered = allBatches.where((batch) {
        return batch.studentmap.containsKey(uid);
      }).toList();

      setState(() {
        userBatches = filtered;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching batches: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return  loadingWidget();

    return ListView.builder(
      itemCount: userBatches.length,
   itemBuilder: (context, index) {
  final batch = userBatches[index];
  final now = DateTime.now();
  final totalDuration = batch.endDate.difference(batch.startDate).inDays;
  final completedDuration = now.difference(batch.startDate).inDays;
  double progress = completedDuration / totalDuration;
  progress = progress.clamp(0.0, 1.0); // ensure between 0 and 1
  final remainingDays = batch.endDate.difference(now).inDays;
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
         
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            color: Colors.green,
            borderRadius: BorderRadius.circular(4),
          ),
                   Text(
            'Completed: ${(progress * 100).toStringAsFixed(1)}%',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
                    ],
      ),
    ),
  );
}

    );
  }
}
 