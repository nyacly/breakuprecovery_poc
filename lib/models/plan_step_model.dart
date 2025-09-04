import 'package:cloud_firestore/cloud_firestore.dart';

class PlanStepModel {
  final String title;
  final int index;
  final bool isPremium;
  final bool completed;
  final DateTime createdAt;
  final String note;

  const PlanStepModel({
    required this.title,
    required this.index,
    required this.isPremium,
    required this.completed,
    required this.createdAt,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'index': index,
    'isPremium': isPremium,
    'completed': completed,
    'createdAt': Timestamp.fromDate(createdAt),
    'note': note,
  };

  factory PlanStepModel.fromJson(Map<String, dynamic> json) => PlanStepModel(
    title: json['title'],
    index: json['index'],
    isPremium: json['isPremium'] ?? false,
    completed: json['completed'] ?? false,
    createdAt: (json['createdAt'] as Timestamp).toDate(),
    note: json['note'] ?? '',
  );

  PlanStepModel copyWith({
    String? title,
    int? index,
    bool? isPremium,
    bool? completed,
    DateTime? createdAt,
    String? note,
  }) => PlanStepModel(
    title: title ?? this.title,
    index: index ?? this.index,
    isPremium: isPremium ?? this.isPremium,
    completed: completed ?? this.completed,
    createdAt: createdAt ?? this.createdAt,
    note: note ?? this.note,
  );
}