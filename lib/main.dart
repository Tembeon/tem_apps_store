import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tem_apps_store/app.dart';

bool isDarkMode = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  var box = await Hive.openBox('settings');

  var brightness = SchedulerBinding.instance.window.platformBrightness;
  isDarkMode = brightness == Brightness.dark;

  if (isDarkMode == null) {
    isDarkMode = false;
  }

  String selectedTheme = box.get('selectedTheme');
  if (selectedTheme == 'dark') {
    isDarkMode = true;
  }
  if (selectedTheme == 'light') {
    isDarkMode = false;
  }

  runApp(TemAppsStore());
}
