import 'package:flutter/material.dart';

ThemeData theme() {
  const appBarText = Colors.white;
  const text = Colors.white;
  const headline6 = Colors.black;
  const headline2 = Colors.black;
  const principalColor = Colors.green;
  const elevatedButtonTextColor = Colors.white;

  return ThemeData(
    useMaterial3: true,
    primaryColor: principalColor,
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      //usado no dropdown
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.grey[50],
      surfaceTintColor: Colors.amber[100],
      shadowColor: principalColor,
      shape: const RoundedRectangleBorder(
        side: BorderSide(
          width: 1,
          color: principalColor,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      elevation: 5,
    ),
    secondaryHeaderColor: text,
    appBarTheme: ThemeData().appBarTheme.copyWith(
          actionsIconTheme: const IconThemeData(
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          toolbarHeight: 40,
          backgroundColor: principalColor,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            letterSpacing: 0.7,
            color: appBarText,
            fontFamily: 'BebasNeue',
            fontSize: 30,
          ),
        ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: text,
        backgroundColor: principalColor,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'OpenSans',
          color: elevatedButtonTextColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: Colors.white,
      shadowColor: Colors.white,
      dividerColor: Colors.amberAccent,
      headerBackgroundColor: principalColor,
      surfaceTintColor: Colors.white,
      headerForegroundColor: Colors.white,
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: principalColor,
      onPrimary: principalColor,
      secondary: const Color.fromARGB(255, 92, 152, 94),
      onSecondary: const Color.fromARGB(255, 92, 152, 94),
      error: Colors.red,
      onError: Colors.red,
      surface: Colors.white,
      onSurface: Colors.white,
    ),
  ).copyWith(
    textTheme: ThemeData.light().textTheme.copyWith(
          titleLarge: const TextStyle(
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
            color: headline6,
            fontSize: 40,
            fontFamily: 'BebasNeue',
          ),
          displayMedium: const TextStyle(
            // letterSpacing: 1,
            fontWeight: FontWeight.bold,
            color: headline2,
            fontSize: 17,
            fontFamily: 'OpenSans',
          ),
          bodyLarge: const TextStyle(
            fontFamily: 'OpenSans',
            color: headline6,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
    colorScheme: ThemeData().colorScheme.copyWith(
          primary: principalColor,
          secondary: text,
          onSecondary: principalColor,
        ),
  );
}
