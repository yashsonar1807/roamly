class UserModel {
  final String id;
  final String name;
  final String username;
  final String profileImage;
  final String bio;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.profileImage,
    required this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      username: json['username'] ?? '',
      profileImage: json['profileImage'] ?? '',
      bio: json['bio'] ?? '',
    );
  }
}
