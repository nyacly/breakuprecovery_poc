import 'package:cloud_firestore/cloud_firestore.dart';

enum Mood {
  terrible,
  bad,
  okay,
  good,
  great;

  String get emoji => switch (this) {
    terrible => '😢',
    bad => '😔',
    okay => '😐',
    good => '🙂',
    great => '😊',
  };
}

class JournalEntryModel {
  final String id;
  final String title;
  final String body;
  final Mood mood;
  final DateTime createdAt;

  const JournalEntryModel({
    required this.id,
    required this.title,
    required this.body,
    required this.mood,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'body': body,
    'mood': mood.name,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory JournalEntryModel.fromJson(String id, Map<String, dynamic> json) => JournalEntryModel(
    id: id,
    title: json['title'],
    body: json['body'],
    mood: Mood.values.firstWhere((m) => m.name == json['mood']),
    createdAt: (json['createdAt'] as Timestamp).toDate(),
  );

  JournalEntryModel copyWith({
    String? title,
    String? body,
    Mood? mood,
    DateTime? createdAt,
  }) => JournalEntryModel(
    id: id,
    title: title ?? this.title,
    body: body ?? this.body,
    mood: mood ?? this.mood,
    createdAt: createdAt ?? this.createdAt,
  );
}