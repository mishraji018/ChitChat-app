import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  final bool conversationTones;
  final String messageTone;
  final String messageVibrate;
  final bool messageHighPriority;
  final String groupTone;
  final String groupVibrate;
  final bool groupHighPriority;
  final String callRingtone;
  final String callVibrate;

  const NotificationSettings({
    this.conversationTones = true,
    this.messageTone = 'Chime',
    this.messageVibrate = 'Default',
    this.messageHighPriority = true,
    this.groupTone = 'Chime',
    this.groupVibrate = 'Default',
    this.groupHighPriority = true,
    this.callRingtone = 'Classic Ring',
    this.callVibrate = 'Default',
  });
}

class NotificationNotifier extends StateNotifier<NotificationSettings> {
  NotificationNotifier() : super(const NotificationSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = NotificationSettings(
      conversationTones: prefs.getBool('conversation_tones') ?? true,
      messageTone: prefs.getString('message_tone') ?? 'Chime',
      messageVibrate: prefs.getString('message_vibrate') ?? 'Default',
      messageHighPriority: prefs.getBool('message_high_priority') ?? true,
      groupTone: prefs.getString('group_tone') ?? 'Chime',
      groupVibrate: prefs.getString('group_vibrate') ?? 'Default',
      groupHighPriority: prefs.getBool('group_high_priority') ?? true,
      callRingtone: prefs.getString('call_ringtone') ?? 'Classic Ring',
      callVibrate: prefs.getString('call_vibrate') ?? 'Default',
    );
  }

  Future<void> updateConversationTones(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('conversation_tones', value);
    state = NotificationSettings(
      conversationTones: value,
      messageTone: state.messageTone,
      messageVibrate: state.messageVibrate,
      messageHighPriority: state.messageHighPriority,
      groupTone: state.groupTone,
      groupVibrate: state.groupVibrate,
      groupHighPriority: state.groupHighPriority,
      callRingtone: state.callRingtone,
      callVibrate: state.callVibrate,
    );
  }

  Future<void> updateMessageTone(String tone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('message_tone', tone);
    state = NotificationSettings(
      conversationTones: state.conversationTones,
      messageTone: tone,
      messageVibrate: state.messageVibrate,
      messageHighPriority: state.messageHighPriority,
      groupTone: state.groupTone,
      groupVibrate: state.groupVibrate,
      groupHighPriority: state.groupHighPriority,
      callRingtone: state.callRingtone,
      callVibrate: state.callVibrate,
    );
  }

  Future<void> updateMessageVibrate(String vibrate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('message_vibrate', vibrate);
    state = NotificationSettings(
      conversationTones: state.conversationTones,
      messageTone: state.messageTone,
      messageVibrate: vibrate,
      messageHighPriority: state.messageHighPriority,
      groupTone: state.groupTone,
      groupVibrate: state.groupVibrate,
      groupHighPriority: state.groupHighPriority,
      callRingtone: state.callRingtone,
      callVibrate: state.callVibrate,
    );
  }

  Future<void> updateMessageHighPriority(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('message_high_priority', value);
    state = NotificationSettings(
      conversationTones: state.conversationTones,
      messageTone: state.messageTone,
      messageVibrate: state.messageVibrate,
      messageHighPriority: value,
      groupTone: state.groupTone,
      groupVibrate: state.groupVibrate,
      groupHighPriority: state.groupHighPriority,
      callRingtone: state.callRingtone,
      callVibrate: state.callVibrate,
    );
  }

  Future<void> updateGroupTone(String tone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('group_tone', tone);
    state = NotificationSettings(
      conversationTones: state.conversationTones,
      messageTone: state.messageTone,
      messageVibrate: state.messageVibrate,
      messageHighPriority: state.messageHighPriority,
      groupTone: tone,
      groupVibrate: state.groupVibrate,
      groupHighPriority: state.groupHighPriority,
      callRingtone: state.callRingtone,
      callVibrate: state.callVibrate,
    );
  }

  Future<void> updateGroupVibrate(String vibrate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('group_vibrate', vibrate);
    state = NotificationSettings(
      conversationTones: state.conversationTones,
      messageTone: state.messageTone,
      messageVibrate: state.messageVibrate,
      messageHighPriority: state.messageHighPriority,
      groupTone: state.groupTone,
      groupVibrate: vibrate,
      groupHighPriority: state.groupHighPriority,
      callRingtone: state.callRingtone,
      callVibrate: state.callVibrate,
    );
  }

  Future<void> updateGroupHighPriority(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('group_high_priority', value);
    state = NotificationSettings(
      conversationTones: state.conversationTones,
      messageTone: state.messageTone,
      messageVibrate: state.messageVibrate,
      messageHighPriority: state.messageHighPriority,
      groupTone: state.groupTone,
      groupVibrate: state.groupVibrate,
      groupHighPriority: value,
      callRingtone: state.callRingtone,
      callVibrate: state.callVibrate,
    );
  }

  Future<void> updateCallRingtone(String tone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('call_ringtone', tone);
    state = NotificationSettings(
      conversationTones: state.conversationTones,
      messageTone: state.messageTone,
      messageVibrate: state.messageVibrate,
      messageHighPriority: state.messageHighPriority,
      groupTone: state.groupTone,
      groupVibrate: state.groupVibrate,
      groupHighPriority: state.groupHighPriority,
      callRingtone: tone,
      callVibrate: state.callVibrate,
    );
  }

  Future<void> updateCallVibrate(String vibrate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('call_vibrate', vibrate);
    state = NotificationSettings(
      conversationTones: state.conversationTones,
      messageTone: state.messageTone,
      messageVibrate: state.messageVibrate,
      messageHighPriority: state.messageHighPriority,
      groupTone: state.groupTone,
      groupVibrate: state.groupVibrate,
      groupHighPriority: state.groupHighPriority,
      callRingtone: state.callRingtone,
      callVibrate: vibrate,
    );
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationSettings>(
  (ref) => NotificationNotifier(),
);
