import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart'; // Tambahkan ini
import 'package:device_info_plus/device_info_plus.dart';
import 'utils.dart';
import 'dart:io';

class NotificationHelper {
  static final _notifications = FlutterLocalNotificationsPlugin();

  Future<void> saveNotificationToFirebase({
    required String userId,
    required String title,
    required String body,
    required int timestamp,
  }) async {
    final notifRef = FirebaseDatabase.instance
        .ref('notifikasi/$userId')
        .push(); // Auto ID

    await notifRef.set({'title': title, 'body': body, 'timestamp': timestamp});
  }

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);

    await _requestExactAlarmPermission(); // Minta izin saat init
  }

  Future<void> scheduleSewaReminder({
    required String lokerId,
    required int expiredAt,
    required String userId,
  }) async {
    final scheduledTime = DateTime.fromMillisecondsSinceEpoch(
      expiredAt,
    ).subtract(const Duration(minutes: 10));

    final title = 'Pengingat Sewa Loker';
    final body = 'Sisa waktu sewa ${namaLoker(lokerId)} tinggal 10 menit!';

    if (scheduledTime.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        lokerId.hashCode,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sewa_channel',
            'Sewa Loker',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      // 🔐 Simpan ke Firebase
      await saveNotificationToFirebase(
        userId: userId,
        title: title,
        body: body,
        timestamp: scheduledTime.millisecondsSinceEpoch,
      );
    }
  }

  /// 🔒 Minta izin exact alarm untuk Android 12+
  Future<void> _requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkVersion();
      if (sdkInt >= 31) {
        final status = await Permission.scheduleExactAlarm.status;
        if (!status.isGranted) {
          final result = await Permission.scheduleExactAlarm.request();
          if (result.isGranted) {
            print('✅ Izin exact alarm diberikan');
          } else {
            print('⚠️ Izin exact alarm ditolak oleh user');
          }
        } else {
          print('✅ Izin exact alarm sudah diberikan');
        }
      }
    }
  }

  /// Ambil SDK Android saat runtime
  Future<int> _getAndroidSdkVersion() async {
    final info = await DeviceInfoPlugin().androidInfo;
    return info.version.sdkInt;
  }
}
