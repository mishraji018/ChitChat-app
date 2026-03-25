class ContactModel {
  final String id;
  final String name;
  final String mobile;
  final bool isOnline;
  final String? avatarUrl;
  final String? bio;

  const ContactModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.isOnline = false,
    this.avatarUrl,
    this.bio,
  });
}
