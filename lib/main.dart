import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'app.dart';
import 'core/data/database/app_database.dart';
import 'core/notifications/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  WakelockPlus.enable();

  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase();

  await NotificationService.instance.init();
  await NotificationService.instance.syncFromPrefs(prefs);

  runApp(App(prefs: prefs, db: db));
}
