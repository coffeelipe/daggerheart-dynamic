import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_application/core/theme/app_pallete.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MyThemePreference { system, light, dark }

class AppTheme {
  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(50),
      );
  static OutlineInputBorder get authBorder => _border(Pallete.primaryOnDark);
  static OutlineInputBorder get focusedAuthBorder =>
      _border(Pallete.accentColor);
  
  InputDecoration otpDecoration() => InputDecoration(
      filled: true,
      counter: Offstage(),
      hintText: '0',
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      ));

  static AppBar topPurpleStripe() {
    return AppBar(
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Pallete.mainColor,
      elevation: 0,
      toolbarHeight: 35,
    );
  }

// Light Theme
  static final lightThemeMode = ThemeData.light().copyWith(
    textTheme: ThemeData.light().textTheme.apply(
          bodyColor: Pallete.primaryOnLight,
          displayColor: Pallete.primaryOnLight,
          fontFamily: 'Poppins',
        ),
    scaffoldBackgroundColor: Pallete.backgroundColorLight,
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: _border(Pallete.primaryOnLight),
      focusedBorder: _border(Pallete.mainColor),
      errorBorder: _border(Pallete.inputErrorColor),
      focusedErrorBorder: _border(Pallete.inputErrorColor),
      fillColor: Pallete.inputColor,
      hintStyle: TextStyle(
        color: Pallete.hintTextColor,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      errorStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Pallete.inputErrorColor,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Pallete.primaryOnLight,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Pallete.primaryOnLight,
        elevation: 10,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Pallete.backgroundColorLight,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: Pallete.primaryOnLight,
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      hintStyle: WidgetStatePropertyAll(
        TextStyle(
          color: Pallete.hintTextColor,
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Pallete.primaryOnDark,
      elevation: 2,
      indicatorShape: CircleBorder(),
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Pallete.mainColor);
        }
        return IconThemeData(color: Pallete.hintTextColor);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: Pallete.mainColor, fontSize: 12.5);
          }
          return TextStyle(color: Pallete.hintTextColor, fontSize: 12.5);
        },
      ),
    ),
    iconTheme: IconThemeData(
      color: Pallete.primaryOnLight,
    ),
    cardTheme: CardTheme(
      color: Pallete.primaryOnDark,
    ),
  );

  // Dark Theme
  static final darkThemeMode = ThemeData.dark().copyWith(
    textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Pallete.primaryOnDark,
          displayColor: Pallete.primaryOnDark,
          fontFamily: 'Poppins',
        ),
    scaffoldBackgroundColor: Pallete.backgroundColorDark,
    inputDecorationTheme: InputDecorationTheme(
        enabledBorder: _border(Pallete.primaryOnDark),
        focusedBorder: _border(Pallete.mainColor),
        errorBorder: _border(Pallete.inputErrorColor),
        focusedErrorBorder: _border(Pallete.inputErrorColor),
        hintStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: Pallete.hintTextColorOnDark,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        errorStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Pallete.inputErrorColor,
        )),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Pallete.primaryOnDark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Pallete.primaryOnDark,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Pallete.backgroundColorDark,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: Pallete.primaryOnDark,
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      hintStyle: WidgetStatePropertyAll(
        TextStyle(
          color: Pallete.hintTextColorOnDark,
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Pallete.primaryOnLight,
      elevation: 2,
      indicatorShape: CircleBorder(),
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Pallete.accentColor);
        }
        return IconThemeData(color: Pallete.hintTextColorOnDark);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: Pallete.accentColor, fontSize: 12.5);
          }
          return TextStyle(color: Pallete.hintTextColorOnDark, fontSize: 12.5);
        },
      ),
    ),
    iconTheme: IconThemeData(
      color: Pallete.primaryOnDark,
    ),
    cardTheme: CardTheme(
      color: Pallete.primaryOnLight,
    ),
    dividerTheme: DividerThemeData(
      color: Pallete.hintTextColorOnDark,
    ),
  );
}
