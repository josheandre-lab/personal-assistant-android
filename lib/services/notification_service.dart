import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:permission_handler/permission_handler.dart';
import '../models/reminder_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  static final StreamController<String?> _notificationResponseController = 
      StreamController<String?>.broadcast();
  
  static Stream<String?> get onNotificationResponse => 
      _notificationResponseController.stream;
  
  static Future<void> initialize() async {
    tz_data.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _notificationResponseController.add(response.payload);
      },
    );
  }
  
  static Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
  
  static Future<bool> checkPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }
  
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'personal_assistant_channel',
      'Kişisel Asistan',
      channelDescription: 'Hatırlatma ve bildirimler',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.show(id, title, body, details, payload: payload);
  }
  
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);
    
    const androidDetails = AndroidNotificationDetails(
      'personal_assistant_channel',
      'Kişisel Asistan',
      channelDescription: 'Hatırlatma ve bildirimler',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
  
  static Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required RepeatInterval interval,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'personal_assistant_channel',
      'Kişisel Asistan',
      channelDescription: 'Hatırlatma ve bildirimler',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      interval,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }
  
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
  
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
  
  static Future<void> scheduleReminder(Reminder reminder) async {
    if (reminder.isCompleted) return;
    
    final payload = 'reminder_${reminder.id}';
    
    switch (reminder.repeatType) {
      case RepeatType.none:
        await scheduleNotification(
          id: reminder.id,
          title: reminder.title,
          body: reminder.description ?? 'Hatırlatma zamanı geldi!',
          scheduledDate: reminder.dateTime,
          payload: payload,
        );
        break;
      case RepeatType.daily:
        await scheduleRepeatingNotification(
          id: reminder.id,
          title: reminder.title,
          body: reminder.description ?? 'Günlük hatırlatma',
          scheduledDate: reminder.dateTime,
          interval: RepeatInterval.daily,
          payload: payload,
        );
        break;
      case RepeatType.weekly:
        await scheduleRepeatingNotification(
          id: reminder.id,
          title: reminder.title,
          body: reminder.description ?? 'Haftalık hatırlatma',
          scheduledDate: reminder.dateTime,
          interval: RepeatInterval.weekly,
          payload: payload,
        );
        break;
      case RepeatType.monthly:
        await scheduleNotification(
          id: reminder.id,
          title: reminder.title,
          body: reminder.description ?? 'Aylık hatırlatma',
          scheduledDate: reminder.dateTime,
          payload: payload,
        );
        break;
    }
  }
  
  static Future<void> scheduleDailyBriefing({
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    await scheduleRepeatingNotification(
      id: 999999,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      interval: RepeatInterval.daily,
      payload: 'daily_briefing',
    );
  }
  
  static Future<void> cancelDailyBriefing() async {
    await cancelNotification(999999);
  }
  
  static void dispose() {
    _notificationResponseController.close();
  }
}
