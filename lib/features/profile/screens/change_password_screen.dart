import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/core/services/api_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();
  bool _isLoading = false;

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isCurrentVisible = false;
  bool _isNewVisible = false;
  bool _isConfirmVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _api.put('/profile/password', {
        'password': _currentPasswordController.text,
        'new_password': _newPasswordController.text,
        'confirmation_password': _confirmPasswordController.text,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.onSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'Change Password',
          style: GoogleFonts.hankenGrotesk(
              color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Current Password', textColor),
              _buildPasswordField(
                controller: _currentPasswordController,
                isVisible: _isCurrentVisible,
                onToggle: () => setState(() => _isCurrentVisible = !_isCurrentVisible),
                hint: 'Enter current password',
              ),
              const SizedBox(height: 20),

              _buildLabel('New Password', textColor),
              _buildPasswordField(
                controller: _newPasswordController,
                isVisible: _isNewVisible,
                onToggle: () => setState(() => _isNewVisible = !_isNewVisible),
                hint: 'Minimum 6 characters',
                validator: (val) {
                  if (val == null || val.length < 6) return 'Minimum 6 characters';
                  if (val == _currentPasswordController.text) return 'Cannot be the same as old password';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildLabel('Confirm New Password', textColor),
              _buildPasswordField(
                controller: _confirmPasswordController,
                isVisible: _isConfirmVisible,
                onToggle: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
                hint: 'Re-enter new password',
                validator: (val) {
                  if (val != _newPasswordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Update Password',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
    required String hint,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      style: TextStyle(color: isDark ? Colors.white : AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.1))),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
          onPressed: onToggle,
        ),
      ),
      validator: validator ?? (val) => val!.isEmpty ? 'This field is required' : null,
    );
  }
}
