import '../../domain/entities/question.dart';

/// نموذج السؤال - Data Layer
/// يمثل بيانات السؤال في Firestore
class QuestionModel extends Question {
  QuestionModel({
    required super.id,
    required super.testId,
    required super.questionText,
    super.imageUrl,
    required super.options,
    required super.correctAnswerIndex,
    super.order,
  });

  /// تحويل إلى Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'testId': testId,
      'questionText': questionText,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'order': order,
    };
  }

  /// إنشاء من Firestore Document
  factory QuestionModel.fromFirestore(String id, Map<String, dynamic> data) {
    return QuestionModel(
      id: id,
      testId: data['testId'] ?? '',
      questionText: data['questionText'] ?? '',
      imageUrl: data['imageUrl'] as String?,
      options: List<String>.from(data['options'] ?? []),
      correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
      order: data['order'] ?? 0,
    );
  }

  /// تحويل من Entity
  factory QuestionModel.fromEntity(Question question) {
    return QuestionModel(
      id: question.id,
      testId: question.testId,
      questionText: question.questionText,
      imageUrl: question.imageUrl,
      options: question.options,
      correctAnswerIndex: question.correctAnswerIndex,
      order: question.order,
    );
  }
}

