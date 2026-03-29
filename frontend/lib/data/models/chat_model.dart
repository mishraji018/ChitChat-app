class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final bool isGroup;
  final String avatar;

  const ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
    required this.isGroup,
    required this.avatar,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final participants = json['participants'] as List<dynamic>? ?? [];
    final isGroup = json['isGroup'] as bool? ?? false;

    String name = '';
    String avatar = '';
    bool isOnline = false;

    if (isGroup) {
      name = json['groupName'] as String? ?? 'Group';
      avatar = json['groupPhoto'] as String? ?? '';
    } else {
      final other = participants.isNotEmpty
          ? participants.first as Map<String, dynamic>
          : <String, dynamic>{};
      name = other['name'] as String? ?? 'Unknown';
      avatar = other['profilePhoto'] as String? ?? '';
      isOnline = other['isOnline'] as bool? ?? false;
    }

    final lastMsg = json['lastMessage'] as Map<String, dynamic>?;
    String lastMessageText = '';
    if (lastMsg != null) {
      final type = lastMsg['type'] as String? ?? 'text';
      if (type == 'text') {
        lastMessageText = lastMsg['content'] as String? ?? '';
      } else if (type == 'image') {
        lastMessageText = '📷 Photo';
      } else if (type == 'video') {
        lastMessageText = '🎥 Video';
      } else if (type == 'audio') {
        lastMessageText = '🎵 Audio';
      } else {
        lastMessageText = '📎 Attachment';
      }
    }

    final updatedAt = json['updatedAt'] as String?;
    String timeStr = '';
    if (updatedAt != null) {
      final dt = DateTime.tryParse(updatedAt);
      if (dt != null) {
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (diff.inMinutes < 60) {
          timeStr = '${diff.inMinutes} min ago';
        } else if (diff.inHours < 24) {
          timeStr = '${diff.inHours} hr ago';
        } else if (diff.inDays == 1) {
          timeStr = 'Yesterday';
        } else {
          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          timeStr = days[dt.weekday - 1];
        }
      }
    }

    return ChatModel(
      id: json['_id'] as String? ?? '',
      name: name,
      lastMessage: lastMessageText,
      time: timeStr,
      unreadCount: json['unreadCount'] as int? ?? 0,
      isOnline: isOnline,
      isGroup: isGroup,
      avatar: avatar,
    );
  }
}