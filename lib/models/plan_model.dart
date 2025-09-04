import 'package:cloud_firestore/cloud_firestore.dart';

class PlanModel {
  final String id;
  final DateTime createdAt;
  final List<int> completedStepIds;

  const PlanModel({
    required this.id,
    required this.createdAt,
    this.completedStepIds = const [],
  });

  Map<String, dynamic> toJson() => {
    'createdAt': Timestamp.fromDate(createdAt),
    'completedStepIds': completedStepIds,
  };

  factory PlanModel.fromJson(String id, Map<String, dynamic> json) => PlanModel(
    id: id,
    createdAt: (json['createdAt'] as Timestamp).toDate(),
    completedStepIds: List<int>.from(json['completedStepIds'] ?? []),
  );

  PlanModel copyWith({
    List<int>? completedStepIds,
  }) => PlanModel(
    id: id,
    createdAt: createdAt,
    completedStepIds: completedStepIds ?? this.completedStepIds,
  );
}