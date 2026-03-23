enum MessageType { text, image, pdf, voice, video, location }

enum MessageStatus { sent, delivered, read }

class MessageModel {
  final String id;
  final String senderId;
  final String? text;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isMe;
  final MessageModel? replyTo;
  final Map<String, List<String>> reactions;
  final bool isStarred;
  final bool isEdited;
  final bool isDeleted;
  final String? mediaUrl;
  final int? duration;

  MessageModel({
    required this.id,
    required this.senderId,
    this.text,
    required this.type,
    required this.timestamp,
    required this.status,
    required this.isMe,
    this.replyTo,
    this.reactions = const {},
    this.isStarred = false,
    this.isEdited = false,
    this.isDeleted = false,
    this.mediaUrl,
    this.duration,
  });

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? text,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    bool? isMe,
    MessageModel? replyTo,
    Map<String, List<String>>? reactions,
    bool? isStarred,
    bool? isEdited,
    bool? isDeleted,
    String? mediaUrl,
    int? duration,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isMe: isMe ?? this.isMe,
      replyTo: replyTo ?? this.replyTo,
      reactions: reactions ?? this.reactions,
      isStarred: isStarred ?? this.isStarred,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      duration: duration ?? this.duration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'isMe': isMe,
      'replyTo': replyTo?.toJson(),
      'reactions': reactions,
      'isStarred': isStarred,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'mediaUrl': mediaUrl,
      'duration': duration,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['senderId'],
      text: json['text'],
      type: MessageType.values.byName(json['type']),
      timestamp: DateTime.parse(json['timestamp']),
      status: MessageStatus.values.byName(json['status']),
      isMe: json['isMe'],
      replyTo: json['replyTo'] != null ? MessageModel.fromJson(json['replyTo']) : null,
      reactions: Map<String, List<String>>.from(json['reactions'] ?? {}),
      isStarred: json['isStarred'] ?? false,
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      mediaUrl: json['mediaUrl'],
      duration: json['duration'],
    );
  }
}
