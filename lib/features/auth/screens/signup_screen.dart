import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/auth_input_field.dart';
import '../../../shared/widgets/pink_gradient_button.dart';
import '../../../data/providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
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

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to Terms & Conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final email = _emailController.text.trim();
    final success = await ref.read(authProvider.notifier).signup(
          _nameController.text.trim(),
          _mobileController.text.trim(),
          email,
          _passkeyController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      context.push('/otp', extra: email);
    } else {
      final errorMessage = ref.read(authProvider).errorMessage ?? 'Signup failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Stack(
          children: [
            Positioned(
              top: -100,
              left: 0,
              right: 0,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.15),
                      theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                    ],
                    radius: 0.8,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          '🐻',
                          style: TextStyle(fontSize: 60),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Create Account',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join ChitChat today',
                        style: TextStyle(fontSize: 14, color: colorScheme.secondary),
                      ),
                      const SizedBox(height: 32),
                      
                      AuthInputField(
                        controller: _nameController,
                        hintText: 'Enter your full name',
                        prefixIcon: Icons.person,
                        enabled: !isLoading,
                        validator: (val) {
                          if (val == null || val.trim().length < 2) {
                            return 'Enter at least 2 characters';
                          }
                          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(val)) {
                            return 'Only letters and spaces allowed';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      AuthInputField(
                        controller: _mobileController,
                        hintText: 'Enter mobile number',
                        prefixText: '+91 ',
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        enabled: !isLoading,
                        validator: (val) {
                          if (val == null || val.length != 10) return 'Enter a valid 10-digit number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      AuthInputField(
                        controller: _emailController,
                        hintText: 'Enter your email',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isLoading,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Email is required';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      AuthInputField(
                        controller: _passkeyController,
                        hintText: 'Create a passkey (min 6 chars)',
                        prefixIcon: Icons.lock,
                        obscureText: _obscurePasskey,
                        enabled: !isLoading,
                        onToggleObscure: () => setState(() => _obscurePasskey = !_obscurePasskey),
                        validator: (val) {
                          if (val == null || val.length < 6) return 'Passkey must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      AuthInputField(
                        controller: _confirmPasskeyController,
                        hintText: 'Confirm passkey',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscureConfirmPasskey,
                        enabled: !isLoading,
                        onToggleObscure: () => setState(() => _obscureConfirmPasskey = !_obscureConfirmPasskey),
                        validator: (val) {
                          if (val != _passkeyController.text) return 'Passkeys do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Checkbox(
                            value: _agreedToTerms,
                            checkColor: colorScheme.onPrimary,
                            side: BorderSide(color: colorScheme.secondary),
                            onChanged: isLoading ? null : (val) {
                              setState(() => _agreedToTerms = val ?? false);
                            },
                          ),
                          Text('I agree to ', style: TextStyle(color: colorScheme.onSurface)),
                          GestureDetector(
                            onTap: () {},
                            child: Text('Terms & Conditions', style: TextStyle(color: colorScheme.primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      PinkGradientButton(
                        text: 'SIGN UP',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _signup,
                      ),
                      const SizedBox(height: 32),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account? ", style: TextStyle(color: colorScheme.secondary)),
                          GestureDetector(
                            onTap: isLoading ? null : () => context.go('/login'),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

