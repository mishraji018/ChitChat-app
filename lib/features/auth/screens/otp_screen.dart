import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../shared/widgets/pink_gradient_button.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String? email;
  const OtpScreen({super.key, this.email});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  final _repo = AuthRepository();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final email = widget.email;
    final otp = _otpController.text.trim();

    if (email == null || otp.length < 6) return;

    final success = await ref.read(authProvider.notifier).verifyOtp(email, otp);

    if (!mounted) return;

    if (success) {
      context.go('/home/chats');
    } else {
      final errorMessage = ref.read(authProvider).errorMessage ?? 'Invalid OTP';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    final email = widget.email;
    if (email == null) return;

    final result = await _repo.resendOtp(email: email);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP Resent!'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to resend OTP'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 48,
      textStyle: TextStyle(fontSize: 20, color: colorScheme.onSurface, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: colorScheme.primary),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: colorScheme.primary.withValues(alpha: 0.2),
        border: Border.all(color: colorScheme.primary),
      ),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                  child: Icon(Icons.email, color: colorScheme.primary, size: 36),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Verify Email',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit OTP to',
                style: TextStyle(fontSize: 14, color: colorScheme.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.email ?? 'your email',
                style: TextStyle(fontSize: 14, color: colorScheme.primary, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              Pinput(
                length: 6,
                controller: _otpController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                enabled: !isLoading,
                onCompleted: (pin) => _verifyOtp(),
              ),
              
              const SizedBox(height: 40),
              PinkGradientButton(
                text: 'VERIFY OTP',
                isLoading: isLoading,
                onPressed: isLoading ? null : _verifyOtp,
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text("Didn't receive OTP? ", style: TextStyle(color: colorScheme.secondary)),
                  GestureDetector(
                    onTap: isLoading ? null : _resendOtp,
                    child: Text(
                      'Resend',
                      style: TextStyle(
                        color: isLoading 
                            ? colorScheme.secondary.withValues(alpha: 0.5) 
                            : colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

