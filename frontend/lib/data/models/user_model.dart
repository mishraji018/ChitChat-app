class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profilePhoto;
  final String about;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profilePhoto,
    required this.about,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? json['_id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        profilePhoto: json['profilePhoto'] ?? '',
        about: json['about'] ?? 'Hey there! I am using ChitChat.',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'profilePhoto': profilePhoto,
        'about': about,
      };

  static UserModel get empty => const UserModel(
        id: '',
        name: '',
        email: '',
        phone: '',
        profilePhoto: '',
        about: '',
      );
}
