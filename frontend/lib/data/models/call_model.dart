enum CallType { voice, video }
enum CallDirection { incoming, outgoing, missed }

class CallModel {
  final String id;
  final String contactName;
  final CallType type;
  final CallDirection direction;
  final DateTime timestamp;
  final int? duration; // seconds

  const CallModel({
    required this.id,
    required this.contactName,
    required this.type,
    required this.direction,
    required this.timestamp,
    this.duration,
  });
}
