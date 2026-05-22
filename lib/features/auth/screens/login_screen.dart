import 'package:flutter/material.dart';
import 'package:gosir/core/services/api_service.dart';
import 'package:gosir/core/theme/app_colors.dart';
import 'package:gosir/features/dashboard/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;
  bool _showIntro = true;

  late final AnimationController _animController;
  late final AnimationController _splashController;
  
  late final Animation<double> _logoScale;
  late final Animation<double> _logoSpacing;
  late final Animation<double> _dotDrop;

  @override
  void initState() {
    super.initState();
    
    // Controller for login form staggered entrance
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Controller for intro splash logo animations
    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _logoSpacing = Tween<double>(begin: -8.0, end: -2.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _dotDrop = Tween<double>(begin: -150.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Start intro animations immediately
    _splashController.forward();

    // Auto-transition to login screen after 2.5 seconds if not skipped
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && _showIntro) {
        _skipIntro();
      }
    });
  }

  void _skipIntro() {
    if (_showIntro) {
      setState(() {
        _showIntro = false;
      });
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _splashController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _api.post('/auth/login', {
        'username': _usernameController.text,
        'password': _passwordController.text,
      });

      final token = res['data']['token'];
      if (token != null) {
        await _api.saveToken(token);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _animate({
    required Widget child,
    required double start,
    required double end,
  }) {
    final fade = CurvedAnimation(
      parent: _animController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ));

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: _showIntro
          ? Scaffold(
              key: const ValueKey('intro_splash'),
              backgroundColor: const Color(0xFF24389c),
              body: Center(
                child: AnimatedBuilder(
                  animation: _splashController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Transform.scale(
                          scale: _logoScale.value,
                          child: Text(
                            'gosir',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: _logoSpacing.value,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, _dotDrop.value),
                          child: Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(left: 3),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFC72C),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            )
          : Scaffold(
              key: const ValueKey('login_content'),
              backgroundColor: isMobile 
                  ? (isDark ? const Color(0xFF121212) : Colors.white) 
                  : (isDark ? const Color(0xFF0F0F12) : const Color(0xFFF8FAFC)),
              body: Center(
                child: SingleChildScrollView(
                  padding: isMobile ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 40.0),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 420),
                    decoration: isMobile
                        ? null
                        : BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2D2E3D) : const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide.none,
                      ),
                      color: Colors.transparent,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header / Brand Area
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                left: 24,
                                right: 24,
                                top: isMobile ? 64 : 40,
                                bottom: 16,
                              ),
                              color: Colors.transparent,
                              child: Column(
                                children: [
                                  // Centered brand logo
                                  _animate(
                                    start: 0.0,
                                    end: 0.5,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          'gosir',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF24389c),
                                            letterSpacing: -1.5,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        Container(
                                          width: 7,
                                          height: 7,
                                          margin: const EdgeInsets.only(left: 2),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFFC72C),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 36),
                                  _animate(
                                    start: 0.1,
                                    end: 0.6,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Login to your Account',
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Form Area
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Error Banner
                                  if (_errorMessage != null) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF4E1616) : const Color(0xFFFFDAD6),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFBA1A1A).withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.error_outline_rounded,
                                            color: isDark ? const Color(0xFFFFB4AB) : AppColors.destructive,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Authentication Failed',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark ? const Color(0xFFFFB4AB) : AppColors.destructive,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  _errorMessage!,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDark ? const Color(0xFFF2EFF9) : const Color(0xFF93000a),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],

                                  // Username Field
                                  _animate(
                                    start: 0.2,
                                    end: 0.7,
                                    child: TextFormField(
                                      controller: _usernameController,
                                      onChanged: (_) {
                                        if (_errorMessage != null) {
                                          setState(() => _errorMessage = null);
                                        }
                                      },
                                      style: TextStyle(
                                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Email',
                                        hintStyle: TextStyle(
                                          color: isDark ? const Color(0xFF757684) : const Color(0xFF94A3B8),
                                          fontSize: 14,
                                        ),
                                        filled: true,
                                        fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8FAFC),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: isDark ? const Color(0xFF2D2E3D) : const Color(0xFFE2E8F0),
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: isDark ? const Color(0xFF2D2E3D) : const Color(0xFFE2E8F0),
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: isDark ? const Color(0xFFBAC3FF) : AppColors.primary,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      validator: (v) => (v == null || v.isEmpty) ? 'Username is required' : null,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Password Field
                                  _animate(
                                    start: 0.3,
                                    end: 0.8,
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      onChanged: (_) {
                                        if (_errorMessage != null) {
                                          setState(() => _errorMessage = null);
                                        }
                                      },
                                      style: TextStyle(
                                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Password',
                                        hintStyle: TextStyle(
                                          color: isDark ? const Color(0xFF757684) : const Color(0xFF94A3B8),
                                          fontSize: 14,
                                        ),
                                        filled: true,
                                        fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8FAFC),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: isDark ? const Color(0xFF2D2E3D) : const Color(0xFFE2E8F0),
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: isDark ? const Color(0xFF2D2E3D) : const Color(0xFFE2E8F0),
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: isDark ? const Color(0xFFBAC3FF) : AppColors.primary,
                                            width: 1.5,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                            size: 20,
                                            color: isDark ? const Color(0xFF757684) : const Color(0xFF94A3B8),
                                          ),
                                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                        ),
                                      ),
                                      validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // Remember Me & Forgot Password
                                  _animate(
                                    start: 0.4,
                                    end: 0.9,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () => setState(() => _rememberMe = !_rememberMe),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: Checkbox(
                                                  value: _rememberMe,
                                                  activeColor: isDark ? const Color(0xFFBAC3FF) : AppColors.primary,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  side: BorderSide(
                                                    color: isDark ? const Color(0xFF757684) : const Color(0xFF94A3B8),
                                                    width: 1.5,
                                                  ),
                                                  onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Remember me',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDark ? const Color(0xFF757684) : AppColors.mutedForeground,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {},
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? const Color(0xFFBAC3FF) : AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Submit Button
                                  _animate(
                                    start: 0.5,
                                    end: 1.0,
                                    child: _InteractiveButton(
                                      onPressed: _isLoading ? null : _handleLogin,
                                      isLoading: _isLoading,
                                      backgroundColor: isDark ? const Color(0xFFBAC3FF) : const Color(0xFF24389C),
                                      foregroundColor: isDark ? const Color(0xFF00105C) : Colors.white,
                                      child: _isLoading
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  isDark ? const Color(0xFF00105C) : Colors.white,
                                                ),
                                              ),
                                            )
                                          : const Text(
                                              'Login',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _InteractiveButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget child;
  final Color backgroundColor;
  final Color foregroundColor;

  const _InteractiveButton({
    required this.onPressed,
    required this.isLoading,
    required this.child,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  State<_InteractiveButton> createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<_InteractiveButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _isPressed
        ? 0.96
        : _isHovered
            ? 1.03
            : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color: widget.onPressed == null
                  ? widget.backgroundColor.withValues(alpha: 0.6)
                  : widget.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: widget.backgroundColor.withValues(alpha: _isHovered ? 0.3 : 0.1),
                  blurRadius: _isHovered ? 16 : 8,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: widget.foregroundColor,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
