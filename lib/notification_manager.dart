import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationManager {
  static final NotificationManager _singleton = NotificationManager.init();

  factory NotificationManager() {
    return _singleton;
  }

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  late InitializationSettings initializationSettings;

  late tz.TZDateTime _scheduledDateTime;

  int _hours = 18;
  int _minutes = 30;

  NotificationManager.init() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    if (Platform.isIOS) {
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()!
          .requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    initialize();
  }

  Future<void> initialize() async {
    _hours =
        (await SharedPreferences.getInstance()).getInt('notification_hours') ??
            18;
    _minutes = (await SharedPreferences.getInstance())
            .getInt('notification_minutes') ??
        30;

    await _flutterLocalNotificationsPlugin.cancelAll();

    await initTimezone();

    initializePlatform();

    _scheduledDateTime = await calculateNextDate();

    showNotification();
  }

  Future<void> initTimezone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<tz.TZDateTime> calculateNextDate() async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local).toLocal();

    tz.TZDateTime newScheduledDateTime =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, _hours, _minutes);

    if (newScheduledDateTime.isBefore(now)) {
      newScheduledDateTime = newScheduledDateTime.add(const Duration(days: 1));
    }

    return newScheduledDateTime;
  }

  Future<void> showNotification() async {
    var androidChannel = const AndroidNotificationDetails(
      'main_channel',
      'Main Channel',
      channelDescription: 'Daily Plank',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    var iosChannel = const IOSNotificationDetails(
      sound: 'default.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    var platformChannel = NotificationDetails(
      android: androidChannel,
      iOS: iosChannel,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Daily Plank',
      'The time for your daily plank has come!',
      _scheduledDateTime,
      platformChannel,
      payload: 'Default_Sound',
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  initializePlatform() {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');

    var initializationSettingsIOS = const IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
  }
}
