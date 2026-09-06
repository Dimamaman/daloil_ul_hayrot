import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

/// Kunlik o'qish eslatmasi servisi.
///
/// Nozik joylar:
/// - Android 13+: POST_NOTIFICATIONS ruxsati runtime'da so'raladi
/// - Android 12+: SCHEDULE_EXACT_ALARM ruxsati sozlamalar orqali beriladi
/// - iOS: alert/badge/sound ruxsatlari so'raladi
/// - Telefon o'chib-yonsa: RECEIVE_BOOT_COMPLETED ruxsati tufayli
///   plugin eslatmalarni avtomatik tiklaydi
/// - Timezone: har doim lokal vaqtda ishlaydi, DST o'zgarsa ham to'g'ri
class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'daily_reminder';
  static const _channelName = 'Kunlik eslatma';
  static const _firstReminderId = 0;
  static const _secondReminderId = 1;

  // Yumshoq, ayblamaydigan matnlar
  static const _title = 'Daloil ul-Hayrot';
  static const _body = "Bugungi o'qish kutmoqda — bir necha daqiqa o'zingiz uchun";

  Future<void> init() async {
    tz_data.initializeTimeZones();
    final tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS: init vaqtida ruxsat SO'RAMAYMIZ — foydalanuvchi sozlamalardan yoqganda so'raymiz
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
    );
  }

  /// Ruxsat so'rash — foydalanuvchi eslatmani yoqmoqchi bo'lganda chaqiriladi.
  /// Qaytaradi: true = ruxsat berildi.
  Future<bool> requestPermission() async {
    // --- Android ---
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      // Android 13+ (API 33): POST_NOTIFICATIONS runtime ruxsati
      final notifGranted = await android.requestNotificationsPermission();
      if (notifGranted != true) return false;

      // Android 12+ (API 31): aniq vaqtli alarm ruxsati
      // Bu sozlamalar sahifasini ochadi — foydalanuvchi qo'lda tasdiqlaydi
      await android.requestExactAlarmsPermission();
    }

    // --- iOS ---
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (granted != true) return false;
    }

    return true;
  }

  /// Kunlik eslatmani jadvalga qo'yish.
  /// [id]: 0 = birinchi vaqt, 1 = ikkinchi vaqt.
  /// [hour], [minute]: lokal vaqt.
  ///
  /// matchDateTimeComponents: DateTimeComponents.time — har kuni takrorlanadi.
  /// Telefon o'chib yonsa, plugin RECEIVE_BOOT_COMPLETED broadcast orqali tiklaydi.
  Future<void> scheduleDailyReminder({
    required int id,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // Agar bugungi vaqt o'tib ketgan bo'lsa, ertaga boshlaydi
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      _title,
      _body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: "Kunlik Daloil ul-Hayrot o'qish eslatmasi",
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Saqlangan sozlamalarga ko'ra eslatmalarni qayta jadvallash.
  /// Ilova ochilganda yoki sozlama o'zgarganda chaqiriladi.
  Future<void> syncFromPrefs(SharedPreferences prefs) async {
    final enabled = prefs.getBool('notification_enabled') ?? false;

    if (!enabled) {
      await cancelAll();
      return;
    }

    // Birinchi vaqt
    final time1 = prefs.getString('notification_time_1');
    if (time1 != null) {
      final parts = time1.split(':');
      await scheduleDailyReminder(
        id: _firstReminderId,
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    // Ikkinchi vaqt (ixtiyoriy)
    final time2 = prefs.getString('notification_time_2');
    if (time2 != null) {
      final parts = time2.split(':');
      await scheduleDailyReminder(
        id: _secondReminderId,
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } else {
      await cancelReminder(_secondReminderId);
    }
  }
}
