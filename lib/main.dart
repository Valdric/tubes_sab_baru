import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/features/auth/screens/login_screen.dart';
import 'package:gosir/features/cashier/services/cart_provider.dart';
import 'package:provider/provider.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const GoSirApp(),
    ),
  );
}

class GoSirApp extends StatelessWidget {
  const GoSirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, ThemeMode currentMode, child) {
        return MaterialApp(
          title: 'GoSir',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              secondary: AppColors.secondary,
              onSecondary: AppColors.secondaryForeground,
              surface: AppColors.background,
              onSurface: AppColors.foreground,
              error: AppColors.destructive,
              onError: AppColors.destructiveForeground,
            ),
            textTheme: GoogleFonts.interTextTheme(
              ThemeData.light().textTheme,
            ).copyWith(
              displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.foreground),
              displayMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.foreground),
              bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.foreground),
              labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.foreground),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              secondary: const Color(0xFF1E293B),
              onSecondary: const Color(0xFFF1F5F9),
              surface: const Color(0xFF1E1E1E),
              onSurface: const Color(0xFFE2E8F0),
              error: const Color(0xFFEF4444),
              onError: const Color(0xFFFFFFFF),
            ),
            textTheme: GoogleFonts.interTextTheme(
              ThemeData.dark().textTheme,
            ).copyWith(
              displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: const Color(0xFFE2E8F0)),
              displayMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: const Color(0xFFE2E8F0)),
              bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: const Color(0xFFE2E8F0)),
              labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFE2E8F0)),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF333333)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF333333)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;
        return IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
          },
        );
      },
    );
  }
}
