import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageRole { coach, user }

class ChatMessageModel {
  final String id;
  final MessageRole role;
  final String text;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'role': role.name,
    'text': text,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory ChatMessageModel.fromJson(String id, Map<String, dynamic> json) => ChatMessageModel(
    id: id,
    role: MessageRole.values.firstWhere((r) => r.name == json['role']),
    text: json['text'],
    createdAt: (json['createdAt'] as Timestamp).toDate(),
  );
}