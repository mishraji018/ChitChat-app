import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  static Future<void> initialize() async {
    if (kIsWeb) return;
    
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    // Create notification channels
    await _createChannels();
  }

  static Future<void> _createChannels() async {
    // Message channel
    const messageChannel = AndroidNotificationChannel(
      'chitchat_messages',
      'Messages',
      description: 'ChitChat message notifications',
      importance: Importance.max, // HIGH PRIORITY
      enableVibration: true,
      playSound: true,
      showBadge: true,
    );

    // Call channel
    const callChannel = AndroidNotificationChannel(
      'chitchat_calls',
      'Calls',
      description: 'ChitChat call notifications',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    // Group channel
    const groupChannel = AndroidNotificationChannel(
      'chitchat_groups',
      'Groups',
      description: 'ChitChat group notifications',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(messageChannel);
    await androidPlugin?.createNotificationChannel(callChannel);
    await androidPlugin?.createNotificationChannel(groupChannel);
  }

  // Show message notification (HIGH PRIORITY = heads up display)
  static Future<void> showMessageNotification({
    required String senderName,
    required String message,
    required String conversationId,
  }) async {
    if (kIsWeb) return;
    
    final prefs = await SharedPreferences.getInstance();
    final highPriority = prefs.getBool('message_high_priority') ?? true;
    final tonesEnabled = prefs.getBool('conversation_tones') ?? true;

    final androidDetails = AndroidNotificationDetails(
      'chitchat_messages',
      'Messages',
      channelDescription: 'ChitChat message notifications',
      importance: Importance.max,
      priority: Priority.high,
      // HIGH PRIORITY = shows as heads-up at top of screen
      fullScreenIntent: highPriority,
      category: AndroidNotificationCategory.message,
      styleInformation: BigTextStyleInformation(message),
      playSound: tonesEnabled,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap(
        '@mipmap/ic_launcher',
      ),
      groupKey: conversationId,
      autoCancel: true,
    );

    final notifDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      conversationId.hashCode,
      senderName,
      message,
      notifDetails,
    );
  }

  // Show group notification
  static Future<void> showGroupNotification({
    required String groupName,
    required String senderName,
    required String message,
    required String groupId,
  }) async {
    if (kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    final highPriority = prefs.getBool('group_high_priority') ?? true;
    final tonesEnabled = prefs.getBool('conversation_tones') ?? true;

    final androidDetails = AndroidNotificationDetails(
      'chitchat_groups',
      'Groups',
      importance: Importance.high,
      priority: Priority.high,
      fullScreenIntent: highPriority,
      playSound: tonesEnabled,
      enableVibration: true,
      groupKey: groupId,
      autoCancel: true,
    );

    await _notifications.show(
      groupId.hashCode,
      '$groupName: $senderName',
      message,
      NotificationDetails(android: androidDetails),
    );
  }

  // Cancel notification
  static Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _notifications.cancel(id);
  }

  // Cancel all
  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _notifications.cancelAll();
  }
}
