import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../shared/widgets/glass_widgets.dart';

class OtpScreen extends StatefulWidget {
  final String? email;
  const OtpScreen({super.key, this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    context.go('/home/chats');
  }

  void _resendOtp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✨ New OTP sent to your email'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 60,
      textStyle: TextStyle(fontSize: 24, color: colorScheme.onSurface, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: colorScheme.primary, width: 2),
      color: colorScheme.primary.withValues(alpha: 0.05),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: GlassBackground(
        isDark: isDark,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.tertiary]),
                    boxShadow: [
                      BoxShadow(color: colorScheme.primary.withValues(alpha: 0.3), blurRadius: 25, spreadRadius: 2),
                    ],
                  ),
                  child: const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 32),
                Text(
                  'Verify Identity',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a 6-digit code to',
                  style: TextStyle(fontSize: 14, color: colorScheme.secondary),
                ),
                Text(
                  widget.email ?? 'your premium email',
                  style: TextStyle(fontSize: 14, color: colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 48),
                
                // Glass Card for OTP Input
                GlassCard(
                  isDark: isDark,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Column(
                    children: [
                      Pinput(
                        length: 6,
                        controller: _otpController,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                        showCursor: true,
                        onCompleted: (pin) => _verifyOtp(),
                      ),
                      const SizedBox(height: 40),
                      
                      GestureDetector(
                        onTap: _verifyOtp,
                        child: Container(
                          width: double.infinity,
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
                            'VERIFY & CONTINUE',
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
                
                const Spacer(),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Didn't receive the code? ", style: TextStyle(color: colorScheme.secondary)),
                    TextButton(
                      onPressed: _resendOtp,
                      child: Text(
                        'Resend Now',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
