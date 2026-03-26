import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/glass_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  final _passkeyController = TextEditingController();
  bool _obscurePasskey = true;

  @override
  void dispose() {
    _mobileController.dispose();
    _passkeyController.dispose();
    super.dispose();
  }

  void _login() {
    context.go('/home/chats');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GlassBackground(
          isDark: isDark,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glass Logo Container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.tertiary],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Text('🐻', style: TextStyle(fontSize: 48)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Sign in to your premium account',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.secondary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Glass Login Card
                    GlassCard(
                      isDark: isDark,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildGlassTextField(
                            controller: _mobileController,
                            hint: 'Mobile Number',
                            icon: Icons.phone_android_rounded,
                            isDark: isDark,
                            colorScheme: colorScheme,
                            prefix: '+91 ',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 20),
                          _buildGlassTextField(
                            controller: _passkeyController,
                            hint: 'Passkey',
                            icon: Icons.key_rounded,
                            isDark: isDark,
                            colorScheme: colorScheme,
                            isPassword: true,
                            obscureText: _obscurePasskey,
                            onToggleVisibility: () {
                              setState(() => _obscurePasskey = !_obscurePasskey);
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-passkey'),
                              style: TextButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: const Text('Forgot Passkey?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Premium Login Button
                          GestureDetector(
                            onTap: _login,
                            child: Container(
                              height: 58,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [colorScheme.primary, colorScheme.tertiary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(alpha: 0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'SIGN IN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Social or Secondary Options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("New to ChitChat? ", style: TextStyle(color: colorScheme.secondary)),
                        GestureDetector(
                          onTap: () => context.push('/signup'),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Dev mode button with glass style
                    Opacity(
                      opacity: 0.6,
                      child: TextButton.icon(
                        onPressed: () => context.go('/home/chats'),
                        icon: const Text('🐻'),
                        label: const Text('Developer Quick Access'),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required ColorScheme colorScheme,
    String? prefix,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          icon: Icon(icon, color: colorScheme.primary.withValues(alpha: 0.7), size: 20),
          prefixText: prefix,
          prefixStyle: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
          hintText: hint,
          hintStyle: TextStyle(color: colorScheme.secondary.withValues(alpha: 0.5), fontWeight: FontWeight.normal),
          border: InputBorder.none,
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: colorScheme.secondary.withValues(alpha: 0.5),
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        ),
      ),
    );
  }
}
