import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final FlutterRingtonePlayer _player = FlutterRingtonePlayer();

  // Play message sent sound
  static Future<void> playMessageSent() async {
    final prefs = await SharedPreferences.getInstance();
    final tonesEnabled = prefs.getBool('conversation_tones') ?? true;
    if (!tonesEnabled) return;

    final ringerMode = await _getRingerMode();
    if (ringerMode == 'silent') return;
    if (ringerMode == 'vibrate') {
      await _vibrate(100);
      return;
    }

    _player.play(
      android: AndroidSounds.notification,
      volume: 0.4,
    );
  }

  // Play message received sound
  static Future<void> playMessageReceived() async {
    final prefs = await SharedPreferences.getInstance();
    final tonesEnabled = prefs.getBool('conversation_tones') ?? true;
    final messageTone = prefs.getString('message_tone') ?? 'Chime';
    final vibrateSetting = prefs.getString('message_vibrate') ?? 'Default';
    if (!tonesEnabled) return;

    final ringerMode = await _getRingerMode();

    if (ringerMode == 'silent') return;

    if (ringerMode == 'vibrate') {
      if (vibrateSetting != 'Never') {
        await _vibrate(400);
      }
      return;
    }

    // Normal mode
    if (messageTone != 'None') {
      _playTone(messageTone);
    }

    if (vibrateSetting == 'Always' || vibrateSetting == 'Default') {
      await _vibrate(300);
    }
  }

  // Play ringtone for incoming call
  static Future<void> playCallRingtone() async {
    final prefs = await SharedPreferences.getInstance();
    final ringtone = prefs.getString('call_ringtone') ?? 'Classic Ring';
    final ringerMode = await _getRingerMode();

    if (ringerMode == 'silent') return;

    if (ringerMode == 'vibrate') {
      _vibratePattern();
      return;
    }

    if (ringtone != 'None') {
      _player.playRingtone();
    }
  }

  static void stopRingtone() {
    _player.stop();
  }

  static void _playTone(String tone) {
    switch (tone) {
      case 'Chime':
        _player.play(
          android: AndroidSounds.notification,
          volume: 0.8,
        );
        break;
      case 'Bell':
        _player.play(
          android: AndroidSounds.notification,
          volume: 0.8,
        );
        break;
      case 'Ping':
        _player.play(
          android: AndroidSounds.notification,
          volume: 0.8,
        );
        break;
      case 'Droplet':
        _player.play(
          android: AndroidSounds.notification,
          volume: 0.8,
        );
        break;
      case 'Default':
        _player.playNotification();
        break;
      case 'None':
        break;
    }
  }

  static Future<void> _vibrate(int duration) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: duration);
    }
  }

  static Future<void> _vibratePattern() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(
        pattern: [0, 500, 200, 500, 200, 500],
        intensities: [0, 255, 0, 255, 0, 255],
      );
    }
  }

  // Get device ringer mode via MethodChannel
  static const _channel = MethodChannel('com.chitchat.app/ringer');

  static Future<String> _getRingerMode() async {
    try {
      final String mode = await _channel.invokeMethod('getRingerMode');
      return mode; // 'silent', 'vibrate', 'normal'
    } catch (e) {
      return 'normal';
    }
  }
}
