
import 'package:flutter/material.dart';

ThemeData themeData(BuildContext context) {
  //light theme
  return ThemeData(
    brightness: Brightness.light,
    // ignore: deprecated_member_use
    textSelectionColor: Color(0xFF777777),
    // ignore: deprecated_member_use
    textSelectionHandleColor: Color(0xFF000000),
    primaryColor: Colors.white,
    accentColor: Colors.black,
    backgroundColor: Colors.white,
    iconTheme: Theme.of(context).iconTheme.copyWith(size: 20.0),
  );
}

ThemeData darkThemeData(BuildContext context) {
  //dark theme
  return ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    // ignore: deprecated_member_use
    textSelectionColor: Color(0xFF777777),
    // ignore: deprecated_member_use
    textSelectionHandleColor: Color(0xFFFFFFFF),
    primaryColor: Color(0xFF222222),
    accentColor: Colors.white,

    iconTheme: Theme.of(context).iconTheme.copyWith(size: 20.0),
  );
}