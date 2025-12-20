import 'package:equatable/equatable.dart';

class ExamsState extends Equatable {
  final List<Map<String, dynamic>> exams;
  final bool isLoading;
  final String? error;

  const ExamsState({
    this.exams = const [],
    this.isLoading = false,
    this.error,
  });

  ExamsState copyWith({
    List<Map<String, dynamic>>? exams,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ExamsState(
      exams: exams ?? this.exams,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [exams, isLoading, error];
}
