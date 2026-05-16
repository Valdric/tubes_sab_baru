import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/features/dashboard/screens/dashboard_screen.dart';
import 'package:gosir/core/services/api_service.dart'; // IMPORT API SERVICE

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false; // TAMBAHKAN LOADING STATE

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService(); // INISIALISASI API SERVICE

  // FUNGSI LOGIKA LOGIN KE API
  void _handleLogin() async {
    // Validasi input kosong
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan Password wajib diisi!'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Panggil fungsi login dari ApiService
      final result = await _apiService.login(
        _usernameController.text,
        _passwordController.text,
      );

      // Jika berhasil (asumsi API return success)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (e) {
      // Jika gagal (error 401 atau masalah koneksi)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo & Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.restaurant_menu,
                            size: 48, color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'GOSIR',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'come and cash',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Form Login
                Text(
                  'Username',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                  enabled: !_isLoading, // Disable input saat loading
                  decoration: InputDecoration(
                    hintText: 'Enter your username',
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.onSurfaceVariant),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Password',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  enabled: !_isLoading, // Disable input saat loading
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.onSurfaceVariant),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() => _isPasswordVisible = !_isPasswordVisible);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : () {},
                    child: const Text('Forgot Password?',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin, // PANGGIL FUNGSI LOGIN
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : Text(
                      'Sign In',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
