class ResourceModel {
  final String id;
  final String type; // audio, article, exercise, meditation
  final String title;
  final String summary;
  final String imageUrl;
  final String url;
  final String duration;
  final List<String> tags;
  final bool premium;
  final DateTime createdAt;

  const ResourceModel({
    required this.id,
    required this.type,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.url,
    required this.duration,
    required this.tags,
    required this.premium,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'title': title,
    'summary': summary,
    'imageUrl': imageUrl,
    'url': url,
    'duration': duration,
    'tags': tags,
    'premium': premium,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ResourceModel.fromJson(String id, Map<String, dynamic> json) => ResourceModel(
    id: id,
    type: json['type'],
    title: json['title'],
    summary: json['summary'],
    imageUrl: json['imageUrl'],
    url: json['url'],
    duration: json['duration'],
    tags: List<String>.from(json['tags'] ?? []),
    premium: json['premium'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
  );
}