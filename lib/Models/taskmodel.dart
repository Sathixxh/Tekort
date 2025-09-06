

// ----------------- models/task_model.dart -----------------
class TaskModel {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String batchId;
  final List<String> assignedUsers;

  TaskModel({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.batchId,
    required this.assignedUsers,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status,
        'batchId': batchId,
        'assignedUsers': assignedUsers,
      };
}

