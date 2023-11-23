import 'package:flutter/material.dart';

const primary = Color.fromRGBO(0x48, 0x5e, 0x6d, 1);
const primaryVariant = Color.fromRGBO(0x1e, 0x34, 0x42, 1);
const primaryLight = Color.fromRGBO(0x75, 0x8b, 0x9b, 1);
const secondary = Color.fromRGBO(0x62, 0xbc, 0xc1, 1);
const secondaryVariant = Color.fromRGBO(0x2b, 0x8c, 0x91, 1);
const secondaryLight = Color.fromRGBO(0x95, 0xef, 0xf4, 1);
const positiveAction = Colors.green;
const negativeAction = Colors.redAccent;
const barrier = Colors.black54;
const link = Colors.blueAccent; // matching flutter_html's default for now
const unreadIndicator = Colors.red;
const blocked = Colors.red;
const sharing = Colors.green;
final reshared = Colors.blue[500];
final liked = Colors.red[900];

const scheme = ColorScheme(
  primary: primary,
  secondary: secondary,
  surface: Colors.white,
  background: Colors.white,
  error: Colors.red,
  onPrimary: Colors.white,
  onSecondary: Colors.black,
  onSurface: Colors.black,
  onBackground: Colors.black,
  onError: Colors.white,
  brightness: Brightness.light
);

final theme = ThemeData.from(colorScheme: scheme, useMaterial3: false);

const darkScheme = ColorScheme(
  primary: primary,
  secondary: secondary,
  surface: const Color(0xff121212),
  background: const Color(0xff121212),
  error: const Color(0xffcf6679),
  onPrimary: Colors.white,
  onSecondary: Colors.black,
  onSurface: Colors.white,
  onBackground: Colors.white,
  onError: Colors.black,
  brightness: Brightness.dark
);

final darkTheme = ThemeData.from(colorScheme: darkScheme, useMaterial3: false).copyWith(
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: darkScheme.onSurface.withOpacity(0.87)
    )
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: secondary
    )
  )
);

Color unreadItemBackground(ThemeData theme) => theme.colorScheme.secondary.withOpacity(0.3);
Color unreadItemBottomBorder(ThemeData theme) => theme.colorScheme.secondaryContainer.withOpacity(0.2);
Color unselectedNavigationItem(ThemeData theme) => theme.colorScheme.onSurface.withOpacity(0.6);
Color inputBorder(ThemeData theme) => theme.colorScheme.onSurface.withOpacity(0.38);
Color outlineButtonBorder(ThemeData theme) => theme.colorScheme.onSurface.withOpacity(0.12);
Color? postInteractionIcon(ThemeData theme) => theme.iconTheme.color?.withOpacity(0.6);
