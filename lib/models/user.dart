/// User model class
class User {
  final String id;
  final String name;
  final String email;
  final DateTime? birthday;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.birthday,
    required this.createdAt,
  });

  /// Creates a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      birthday:
          json['birthday'] != null
              ? DateTime.parse(json['birthday'] as String)
              : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'birthday': birthday?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
