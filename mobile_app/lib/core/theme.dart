import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'hive_init.dart';

ThemeData buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.seed, brightness: Brightness.light);
  final textTheme = AppTypography.light(colorScheme);
  return ThemeData(
    colorScheme: colorScheme,
    textTheme: textTheme,
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(RadiusTheme().md)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(RadiusTheme().md)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.all(RadiusTheme().md)),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      SpacingTheme(),
      RadiusTheme(),
      ElevationTheme(),
    ],
  );
}

ThemeData buildDarkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.seed,
    brightness: Brightness.dark,
  );
  final textTheme = AppTypography.dark(colorScheme);
  return ThemeData(
    colorScheme: colorScheme,
    textTheme: textTheme,
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(RadiusTheme().md)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(RadiusTheme().md)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.all(RadiusTheme().md)),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      SpacingTheme(),
      RadiusTheme(),
      ElevationTheme(),
    ],
  );
}

// Seed color provider to allow runtime theme switching
final seedColorProvider = StateProvider<Color>((ref) {
  final cache = ref.read(appCacheProvider);
  final value = cache.getPref<int>('theme_seed');
  return value != null ? Color(value) : AppColors.seed;
});

ThemeData buildThemeFromSeed(Color seed, Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  final textTheme = brightness == Brightness.dark ? AppTypography.dark(colorScheme) : AppTypography.light(colorScheme);
  return ThemeData(
    colorScheme: colorScheme,
    textTheme: textTheme,
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(RadiusTheme().md)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(RadiusTheme().md)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.all(RadiusTheme().md)),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      SpacingTheme(),
      RadiusTheme(),
      ElevationTheme(),
    ],
  );
}


