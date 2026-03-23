import 'dart:convert';

class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isOnline;
  final bool isPinned;
  final bool isMuted;
  final bool isArchived;
  final String? avatarUrl;
  final String messageStatus; // 'sent', 'delivered', 'read', or ''

  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isPinned = false,
    this.isMuted = false,
    this.isArchived = false,
    this.avatarUrl,
    this.messageStatus = '',
  });

  ChatModel copyWith({
    String? id,
    String? name,
    String? lastMessage,
    String? timestamp,
    int? unreadCount,
    bool? isOnline,
    bool? isPinned,
    bool? isMuted,
    bool? isArchived,
    String? avatarUrl,
    String? messageStatus,
  }) {
    return ChatModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      isArchived: isArchived ?? this.isArchived,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      messageStatus: messageStatus ?? this.messageStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lastMessage': lastMessage,
      'timestamp': timestamp,
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'isPinned': isPinned,
      'isMuted': isMuted,
      'isArchived': isArchived,
      'avatarUrl': avatarUrl,
      'messageStatus': messageStatus,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      timestamp: map['timestamp'] ?? '',
      unreadCount: map['unreadCount']?.toInt() ?? 0,
      isOnline: map['isOnline'] ?? false,
      isPinned: map['isPinned'] ?? false,
      isMuted: map['isMuted'] ?? false,
      isArchived: map['isArchived'] ?? false,
      avatarUrl: map['avatarUrl'],
      messageStatus: map['messageStatus'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatModel.fromJson(String source) => ChatModel.fromMap(json.decode(source));
}
