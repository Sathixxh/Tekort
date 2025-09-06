import 'package:cloud_firestore/cloud_firestore.dart';

class BatchModel {
  final String id;
  final String batchCode;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> studentmap;
  final int studentCount;

  BatchModel({
    required this.id,
    required this.batchCode,
    required this.startDate,
    required this.endDate,
    required this.studentmap,
    required this.studentCount,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json, String id) {
    return BatchModel(
      id: id,
      batchCode: json['batchCode'] ?? '',
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      studentmap: Map<String, dynamic>.from(json['studentmap'] ?? {}),
      studentCount: json['studentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchCode': batchCode,
      'startDate': startDate,
      'endDate': endDate,
      'studentmap': studentmap,
      'studentCount': studentCount,
    };
  }
}
