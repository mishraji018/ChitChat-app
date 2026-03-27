class PrivacySettings {
  final String lastSeen;
  final String profilePhoto;
  final String about;
  final String status;
  final bool readReceipts;
  final bool silenceUnknownCallers;
  final int defaultMessageTimer;
  final bool appLock;

  const PrivacySettings({
    required this.lastSeen,
    required this.profilePhoto,
    required this.about,
    required this.status,
    required this.readReceipts,
    required this.silenceUnknownCallers,
    required this.defaultMessageTimer,
    required this.appLock,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      lastSeen: json['lastSeen'] ?? 'everyone',
      profilePhoto: json['profilePhoto'] ?? 'everyone',
      about: json['about'] ?? 'everyone',
      status: json['status'] ?? 'contacts',
      readReceipts: json['readReceipts'] ?? true,
      silenceUnknownCallers: json['silenceUnknownCallers'] ?? false,
      defaultMessageTimer: json['defaultMessageTimer'] ?? 0,
      appLock: json['appLock'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'lastSeen': lastSeen,
        'profilePhoto': profilePhoto,
        'about': about,
        'status': status,
        'readReceipts': readReceipts,
        'silenceUnknownCallers': silenceUnknownCallers,
        'defaultMessageTimer': defaultMessageTimer,
        'appLock': appLock,
      };

  PrivacySettings copyWith({
    String? lastSeen,
    String? profilePhoto,
    String? about,
    String? status,
    bool? readReceipts,
    bool? silenceUnknownCallers,
    int? defaultMessageTimer,
    bool? appLock,
  }) {
    return PrivacySettings(
      lastSeen: lastSeen ?? this.lastSeen,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      about: about ?? this.about,
      status: status ?? this.status,
      readReceipts: readReceipts ?? this.readReceipts,
      silenceUnknownCallers: silenceUnknownCallers ?? this.silenceUnknownCallers,
      defaultMessageTimer: defaultMessageTimer ?? this.defaultMessageTimer,
      appLock: appLock ?? this.appLock,
    );
  }

  static PrivacySettings get defaults => const PrivacySettings(
        lastSeen: 'everyone',
        profilePhoto: 'everyone',
        about: 'everyone',
        status: 'contacts',
        readReceipts: true,
        silenceUnknownCallers: false,
        defaultMessageTimer: 0,
        appLock: false,
      );
}
