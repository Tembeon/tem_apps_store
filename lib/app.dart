// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_router/flutter_web_router.dart';
import 'package:get/get.dart';
import 'package:tem_apps_store/ui/screens/home.dart';
import 'package:tem_apps_store/ui/screens/view_app.dart';
import 'package:tem_apps_store/ui/theme.dart';

import 'main.dart';

class TemAppsStore extends StatelessWidget {
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    final router = WebRouter();
    router.addRoute(HomeScreen.routeName, (request) => HomeScreen());
    router.addRoute(
        '${ViewApp.routeName}/{id}',
        (request) => ViewApp(
              publicAppName: Uri.parse(request.settings.name)
                  .path
                  .replaceAll(ViewApp.routeName, ''),
            ));

    final loader = document.getElementsByClassName('loader');
    if(loader.isNotEmpty) {
      loader.first.remove();
    }

    return GetMaterialApp(
      title: 'TemApps',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? darkThemeData(context) : themeData(context),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      initialRoute: '/',
      onGenerateRoute: router.build(),
      // routes: {
      //   HomeScreen.routeName: (context) => HomeScreen(),
      //   ViewApp.routeName: (context) => ViewApp(),
      // },
    );
  }
}
