class VideoModel {
  final String id;
  final String courseId;
  final String title;
  final String url;
  final String? description;
  final String duration;
  final DateTime createdAt;

  VideoModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.url,
    this.description,
    this.duration = '00:00',
    required this.createdAt,
  });

  // Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'courseId': courseId,
      'title': title,
      'url': url,
      'description': description ?? '',
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore Document
  factory VideoModel.fromFirestore(String id, Map<String, dynamic> data) {
    return VideoModel(
      id: id,
      courseId: data['courseId'] ?? '',
      title: data['title'] ?? '',
      url: data['url'] ?? '',
      description: data['description'],
      duration: data['duration'] ?? '00:00',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }
}
