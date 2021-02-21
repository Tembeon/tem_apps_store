import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tem_apps_store/app.dart';

bool isDarkMode = false;

Future<void> main() async {
  // Initialize libs
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  var box = await Hive.openBox('settings');

  // get system theme
  var brightness = SchedulerBinding.instance.window.platformBrightness;
  isDarkMode = brightness == Brightness.dark;

  // idk, can we got null or not, but I don't want to get null
  if (isDarkMode == null) {
    isDarkMode = false;
  }

  // read data from storage
  String selectedTheme = box.get('selectedTheme');
  if (selectedTheme == 'dark') {
    isDarkMode = true;
  }
  if (selectedTheme == 'light') {
    isDarkMode = false;
  }

  runApp(TemAppsStore());
}
