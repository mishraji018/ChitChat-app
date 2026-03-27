class PasskeyModel {
  final String id;
  final String deviceName;
  final DateTime createdAt;

  const PasskeyModel({
    required this.id,
    required this.deviceName,
    required this.createdAt,
  });

  factory PasskeyModel.fromJson(Map<String, dynamic> json) => PasskeyModel(
        id: json['id'] ?? '',
        deviceName: json['deviceName'] ?? 'Unknown device',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );
}

class AccountInfo {
  final String email;
  final String phone;
  final List<PasskeyModel> passkeys;

  const AccountInfo({
    required this.email,
    required this.phone,
    required this.passkeys,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) => AccountInfo(
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        passkeys: (json['passkeys'] as List<dynamic>? ?? [])
            .map((e) => PasskeyModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static AccountInfo get empty =>
      const AccountInfo(email: '', phone: '', passkeys: []);
}
