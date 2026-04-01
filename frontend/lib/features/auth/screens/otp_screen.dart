import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../providers/v3/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
  final TextEditingController _otpCtrl = TextEditingController();
  int _resendSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    listenForCode(); // Start listening for SMS
  }

  @override
  void codeUpdated() {
    // This is called when an SMS with the app hash is received
    setState(() {
      _otpCtrl.text = code ?? '';
    });
    if (_otpCtrl.text.length == 6) {
      _verify();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    cancel(); // Stop listening for SMS
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _verify() async {
    final otp = _otpCtrl.text;
    if (otp.length < 6) {
      _snack('Enter the full 6-digit OTP');
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(phone: widget.phone, otp: otp);
    
    if (ok && mounted) {
      context.go('/home/chats');
    } else if (mounted) {
      _snack(auth.error ?? 'Verification failed');
    }
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(name: 'User', phone: widget.phone);
    if (ok) {
      _snack('OTP resent to ${widget.phone}');
      _startTimer();
      listenForCode();
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text('📱', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text('Verify your number',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit OTP sent to\n${widget.phone}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 40),

              // OTP input field with Auto-fill support
              PinFieldAutoFill(
                controller: _otpCtrl,
                decoration: UnderlineDecoration(
                  textStyle: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  colorBuilder: FixedColorBuilder(theme.colorScheme.primary),
                ),
                currentCode: _otpCtrl.text,
                onCodeSubmitted: (code) => _verify(),
                onCodeChanged: (code) {
                  if (code?.length == 6) {
                    _verify();
                  }
                },
                codeLength: 6,
              ),
              
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: auth.isLoading ? null : _verify,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Verify & Login', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),

              // Resend timer
              _resendSeconds > 0
                  ? Text(
                      'Resend OTP in ${_resendSeconds}s',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    )
                  : TextButton(
                      onPressed: _resend,
                      child: const Text('Resend OTP'),
                    ),
                    
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Edit Phone Number'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
