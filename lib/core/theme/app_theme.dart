import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    const seed = Color(0xFFFF4B2B);
    const accent = Color(0xFFFF7A00);
    const deepRed = Color(0xFFD92718);

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
      ).copyWith(
        primary: seed,
        secondary: accent,
        tertiary: deepRed,
        surface: Colors.white,
        onSurface: const Color(0xFF241C18),
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: const Color(0xFFFFFBF9),
        surfaceContainer: const Color(0xFFF8F1ED),
        surfaceContainerHigh: const Color(0xFFF2E7E1),
        surfaceContainerHighest: const Color(0xFFEDE1DA),
      ),
      scaffoldBackgroundColor: const Color(0xFFF4F6F8),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color(0xFFF4F6F8),
        surfaceTintColor: Colors.transparent,
        foregroundColor: Color(0xFF241C18),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF241C18)),
        bodyMedium: TextStyle(color: Color(0xFF241C18)),
        bodySmall: TextStyle(color: Color(0xFF6D625D)),
        titleLarge:
            TextStyle(color: Color(0xFF241C18), fontWeight: FontWeight.w800),
        titleMedium:
            TextStyle(color: Color(0xFF241C18), fontWeight: FontWeight.w800),
        titleSmall:
            TextStyle(color: Color(0xFF241C18), fontWeight: FontWeight.w800),
        headlineLarge:
            TextStyle(color: Color(0xFF241C18), fontWeight: FontWeight.w900),
        headlineMedium:
            TextStyle(color: Color(0xFF241C18), fontWeight: FontWeight.w900),
        headlineSmall:
            TextStyle(color: Color(0xFF241C18), fontWeight: FontWeight.w900),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: deepRed,
          side: const BorderSide(color: Color(0xFFFF4B2B)),
          minimumSize: const Size.fromHeight(48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: seed,
        backgroundColor: Colors.white,
        labelStyle: const TextStyle(
          color: Color(0xFF241C18),
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xFFE0E3EA)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        indicatorColor: const Color(0xFFFFE0D7),
        backgroundColor: Colors.white,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? seed
                : const Color(0xFF8B8D98),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Color(0xFF6D625D)),
        hintStyle: const TextStyle(color: Color(0xFF9B918C)),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2D8D2)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: seed),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: Color(0xFF241C18),
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        contentTextStyle: const TextStyle(color: Color(0xFF241C18)),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFFFFBF9)),
      listTileTheme: const ListTileThemeData(
        iconColor: Color(0xFFFF4B2B),
        textColor: Color(0xFF241C18),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: Colors.white,
        textStyle: TextStyle(color: Color(0xFF241C18)),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(color: Color(0xFF241C18)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFFFFFBF9),
        surfaceTintColor: Colors.transparent,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: deepRed),
      ),
    );
  }

  static ThemeData get darkTheme {
    const seed = Color(0xFFFF6A3D);
    const accent = Color(0xFFFF9B2F);
    const deepRed = Color(0xFFFF4B2B);

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ).copyWith(
        primary: seed,
        secondary: accent,
        tertiary: deepRed,
        surface: const Color(0xFF241916),
        onSurface: const Color(0xFFFFF7F4),
        surfaceContainerLowest: const Color(0xFF1A100D),
        surfaceContainerLow: const Color(0xFF241916),
        surfaceContainer: const Color(0xFF2D1F1A),
        surfaceContainerHigh: const Color(0xFF382721),
        surfaceContainerHighest: const Color(0xFF442F28),
      ),
      scaffoldBackgroundColor: const Color(0xFF17110F),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Color(0xFFFFF7F4),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF241916),
        elevation: 1,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFF7EDE9)),
        bodyMedium: TextStyle(color: Color(0xFFF7EDE9)),
        bodySmall: TextStyle(color: Color(0xFFCDB8AF)),
        titleLarge:
            TextStyle(color: Color(0xFFFFF7F4), fontWeight: FontWeight.w800),
        titleMedium:
            TextStyle(color: Color(0xFFFFF7F4), fontWeight: FontWeight.w800),
        titleSmall:
            TextStyle(color: Color(0xFFFFF7F4), fontWeight: FontWeight.w800),
        headlineLarge:
            TextStyle(color: Color(0xFFFFF7F4), fontWeight: FontWeight.w900),
        headlineMedium:
            TextStyle(color: Color(0xFFFFF7F4), fontWeight: FontWeight.w900),
        headlineSmall:
            TextStyle(color: Color(0xFFFFF7F4), fontWeight: FontWeight.w900),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: seed,
          side: const BorderSide(color: seed),
          minimumSize: const Size.fromHeight(48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        indicatorColor: const Color(0xFF4A2018),
        backgroundColor: const Color(0xFF241916),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF241A12),
        labelStyle: const TextStyle(color: Color(0xFFE5C9BE)),
        hintStyle: const TextStyle(color: Color(0xFFB99D93)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: seed),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: seed,
        backgroundColor: const Color(0xFF241916),
        labelStyle: const TextStyle(
          color: Color(0xFFFFF7F4),
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xFF6B4A40)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF241916),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: Color(0xFFFFF7F4),
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        contentTextStyle: const TextStyle(color: Color(0xFFFFF7F4)),
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1A100D)),
      listTileTheme: const ListTileThemeData(
        iconColor: Color(0xFFFF6A3D),
        textColor: Color(0xFFFFF7F4),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: Color(0xFF241916),
        textStyle: TextStyle(color: Color(0xFFFFF7F4)),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(color: Color(0xFFFFF7F4)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1A100D),
        surfaceTintColor: Colors.transparent,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: seed),
      ),
    );
  }
}
