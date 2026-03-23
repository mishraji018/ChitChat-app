import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Splash Screen')));
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Login Screen')));
}

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Signup Screen')));
}

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('OTP Screen')));
}
