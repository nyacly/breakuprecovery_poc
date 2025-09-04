class UserModel {
  final String uid;
  final String? displayName;
  final String? locale;
  final bool isPremium;
  final List<String> traits;
  final String? activePlanId;

  const UserModel({
    required this.uid,
    this.displayName,
    this.locale,
    this.isPremium = false,
    this.traits = const [],
    this.activePlanId,
  });

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'locale': locale,
    'isPremium': isPremium,
    'traits': traits,
    'activePlanId': activePlanId,
  };

  factory UserModel.fromJson(String uid, Map<String, dynamic> json) => UserModel(
    uid: uid,
    displayName: json['displayName'],
    locale: json['locale'],
    isPremium: json['isPremium'] ?? false,
    traits: List<String>.from(json['traits'] ?? []),
    activePlanId: json['activePlanId'],
  );

  UserModel copyWith({
    String? displayName,
    String? locale,
    bool? isPremium,
    List<String>? traits,
    String? activePlanId,
  }) => UserModel(
    uid: uid,
    displayName: displayName ?? this.displayName,
    locale: locale ?? this.locale,
    isPremium: isPremium ?? this.isPremium,
    traits: traits ?? this.traits,
    activePlanId: activePlanId ?? this.activePlanId,
  );
}