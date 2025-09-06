class CourseModel {
  final String id;
  final String title;
  final String subtitle;
  final String duration;
  final String description;
  final int studentCount;

  CourseModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.description,
    this.studentCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'duration': duration,
      'description': description,
      'studentCount': studentCount,
    };
  }

  factory CourseModel.fromMap(String id, Map<String, dynamic> map) {
    return CourseModel(
      id: id,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      duration: map['duration'] ?? '',
      description: map['description'] ?? '',
      studentCount: map['studentCount'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'CourseModel(id: $id, title: $title, subtitle: $subtitle, duration: $duration, description: $description, studentCount: $studentCount)';
  }
}
