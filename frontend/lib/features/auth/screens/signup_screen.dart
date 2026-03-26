import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/glass_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passkeyController = TextEditingController();
  final _confirmPasskeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePasskey = true;
  bool _obscureConfirmPasskey = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passkeyController.dispose();
    _confirmPasskeyController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please agree to the Terms & Conditions')),
        );
        return;
      }
      context.go('/home/chats');
    }
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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Create Account',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: GlassBackground(
          isDark: isDark,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text('🐻', style: TextStyle(fontSize: 50)),
                    const SizedBox(height: 12),
                    Text(
                      'Join ChitChat',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Experience premium messaging',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.secondary.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    GlassCard(
                      isDark: isDark,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildGlassTextField(
                            controller: _nameController,
                            hint: 'Full Name',
                            icon: Icons.person_outline_rounded,
                            isDark: isDark,
                            colorScheme: colorScheme,
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildGlassTextField(
                            controller: _mobileController,
                            hint: 'Mobile Number',
                            icon: Icons.phone_android_rounded,
                            isDark: isDark,
                            colorScheme: colorScheme,
                            prefix: '+91 ',
                            keyboardType: TextInputType.phone,
                            validator: (val) => val == null || val.length != 10 ? 'Invalid number' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildGlassTextField(
                            controller: _emailController,
                            hint: 'Email (Optional)',
                            icon: Icons.alternate_email_rounded,
                            isDark: isDark,
                            colorScheme: colorScheme,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _buildGlassTextField(
                            controller: _passkeyController,
                            hint: 'New Passkey',
                            icon: Icons.lock_outline_rounded,
                            isDark: isDark,
                            colorScheme: colorScheme,
                            isPassword: true,
                            obscureText: _obscurePasskey,
                            onToggleVisibility: () => setState(() => _obscurePasskey = !_obscurePasskey),
                            validator: (val) => val == null || val.length < 6 ? 'Min 6 characters' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildGlassTextField(
                            controller: _confirmPasskeyController,
                            hint: 'Confirm Passkey',
                            icon: Icons.lock_reset_rounded,
                            isDark: isDark,
                            colorScheme: colorScheme,
                            isPassword: true,
                            obscureText: _obscureConfirmPasskey,
                            onToggleVisibility: () => setState(() => _obscureConfirmPasskey = !_obscureConfirmPasskey),
                            validator: (val) => val != _passkeyController.text ? 'Not matching' : null,
                          ),
                          const SizedBox(height: 20),
                          
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _agreedToTerms,
                                  activeColor: colorScheme.primary,
                                  onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'I agree to the ',
                                      style: TextStyle(color: colorScheme.secondary, fontSize: 12),
                                      children: [
                                        TextSpan(
                                          text: 'Terms & Conditions',
                                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 28),
                          
                          GestureDetector(
                            onTap: _signup,
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
                                'CREATE ACCOUNT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already a member? ", style: TextStyle(color: colorScheme.secondary)),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
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
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 15),
            decoration: InputDecoration(
              icon: Icon(icon, color: colorScheme.primary.withValues(alpha: 0.7), size: 18),
              prefixText: prefix,
              prefixStyle: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
              hintText: hint,
              hintStyle: TextStyle(color: colorScheme.secondary.withValues(alpha: 0.5), fontWeight: FontWeight.normal, fontSize: 14),
              border: InputBorder.none,
              errorStyle: const TextStyle(height: 0), // Hide default error text to keep it clean
              suffixIcon: isPassword 
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: colorScheme.secondary.withValues(alpha: 0.5),
                      size: 18,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            ),
          ),
        ),
      ],
    );
  }
}
