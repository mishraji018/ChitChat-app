import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Check ringer mode
const platform = MethodChannel('com.chitchat.app/ringer');

Future<String> getRingerMode() async {
  try {
    final String mode = await platform.invokeMethod('getRingerMode');
    return mode; // 'silent', 'vibrate', 'normal'
  } catch (e) {
    return 'normal';
  }
}

// Play notification sound
void playNotificationSound(String tone) {
  if (tone == 'None') return;
  FlutterRingtonePlayer().playNotification();
}

// Play ringtone
void playRingtone(String tone) {
  if (tone == 'None') return;
  FlutterRingtonePlayer().playRingtone();
}

// Vibration
void triggerVibration() async {
  if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate(duration: 500);
  }
}

void handleIncomingMessage() async {
  final prefs = await SharedPreferences.getInstance();
  final tone = prefs.getString('message_tone') ?? 'Chime';
  final vibrate = prefs.getString('message_vibrate') ?? 'Default';
  final conversationTones = prefs.getBool('conversation_tones') ?? true;
  
  // Check device ringer mode
  final ringerMode = await getRingerMode();
  
  if (ringerMode == 'silent') {
    // No sound, no vibration
    return;
  }
  
  if (ringerMode == 'vibrate') {
    // Only vibrate
    if (vibrate != 'Never') {
      Vibration.vibrate(duration: 500);
    }
    return;
  }
  
  // Normal mode
  if (conversationTones && tone != 'None') {
    playNotificationSound(tone);
  }
  
  if (vibrate == 'Always' || vibrate == 'Default') {
    Vibration.vibrate(duration: 300);
  }
}
