class UserModel {
  final String id;
  final bool isOnline;
  final List<String> contacts;

  UserModel({required this.id, required this.isOnline, this.contacts = const []});

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      isOnline: json['isOnline'] ?? false,
      contacts: json['contacts'] != null ? List<String>.from(json['contacts']) : [],
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'isOnline': isOnline, 'contacts': contacts};
  }
}
