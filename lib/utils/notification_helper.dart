import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import 'sound_helper.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.actionId == 'stop_alarm') {
          SoundHelper.stop();
          Vibration.cancel();
          _notifications.cancelAll();
        }
      },
    );

    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  static Future<void> showTimerFinished(String timerId, String label) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 1000, 500, 2000, 500, 2000]);
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'timer_channel_id_v3',
      'Alarmas Críticas',
      channelDescription: 'Sonar fuerte y mostrar banner en pantalla',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,

      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,

      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'stop_alarm',
          'DETENER TEMPORIZADOR',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      timerId.hashCode,
      '¡TIEMPO TERMINADO!',
      'La muestra "$label" está lista.',
      details,
    );
  }
}