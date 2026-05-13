import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tubes_ppm_sab/core/theme/app_colors.dart';
import 'package:tubes_ppm_sab/features/auth/screens/login_screen.dart'; // Import Login

void main() {
  runApp(const LumiPOSApp());
}

class LumiPOSApp extends StatelessWidget {
  const LumiPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LumiPOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        // Konfigurasi TextTheme global sesuai DESIGN.md
        textTheme: TextTheme(
          displayLarge: GoogleFonts.hankenGrotesk(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.onSurface),
          displayMedium: GoogleFonts.hankenGrotesk(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          bodyLarge: GoogleFonts.hankenGrotesk(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
          labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        ),
      ),
      home: const LoginScreen(), // Mulai dari Login
    );
  }
}