import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';
import 'package:tubes_ppm_sab/features/auth/screens/login_screen.dart';

// VARIABEL GLOBAL UNTUK MENGATUR TEMA
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const LumiPOSApp());
}

class LumiPOSApp extends StatelessWidget {
  const LumiPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      // HINT BIRU SELESAI: Penamaan parameter udah bener
      builder: (context, ThemeMode currentMode, child) {
        return MaterialApp(
          title: 'LumiPOS',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.surface,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light),
            textTheme: TextTheme(
              displayLarge: GoogleFonts.hankenGrotesk(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.onSurface),
              displayMedium: GoogleFonts.hankenGrotesk(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface),
              bodyLarge: GoogleFonts.hankenGrotesk(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
              labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.dark),
            textTheme: TextTheme(
              displayLarge: GoogleFonts.hankenGrotesk(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
              displayMedium: GoogleFonts.hankenGrotesk(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
              bodyLarge: GoogleFonts.hankenGrotesk(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white70),
              labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),

          home: const LoginScreen(),
        );
      },
    );
  }
}