class BigFiveQuestionModel {
  final String id;
  final String trait; // O|C|E|A|N
  final String text;
  final bool reverse;
  final int order;

  const BigFiveQuestionModel({
    required this.id,
    required this.trait,
    required this.text,
    required this.reverse,
    required this.order,
  });

  Map<String, dynamic> toJson() => {
    'trait': trait,
    'text': text,
    'reverse': reverse,
    'order': order,
  };

  factory BigFiveQuestionModel.fromJson(String id, Map<String, dynamic> json) => BigFiveQuestionModel(
    id: id,
    trait: json['trait'],
    text: json['text'],
    reverse: json['reverse'] ?? false,
    order: json['order'],
  );
}