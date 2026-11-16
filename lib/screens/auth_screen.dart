import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_founds_simple/providers/app_provider.dart';
import 'package:lost_and_founds_simple/screens/home_screen.dart';
import 'package:lost_and_founds_simple/theme/app_theme.dart';
import 'package:lost_and_founds_simple/util.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneNoController = TextEditingController();

  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _phoneNoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<AppProvider>();

    final result = _isLoginMode
        ? await provider.login(
            _emailController.text,
            _passwordController.text,
          )
        : await provider.register(
            email: _emailController.text,
            username: _usernameController.text,
            password: _passwordController.text,
            phoneNo: _phoneNoController.text,
          );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showAppSnackBar(
      context,
      message: result.message,
      isError: !result.success,
    );

    if (result.success && result.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(user: result.user!),
        ),
      );
    }
  }

  void _fillDemoUser() {
    setState(() {
      _isLoginMode = true;
      _emailController.text = 'omar@gmail.com';
      _passwordController.text = 'Omar';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.travel_explore_rounded,
                      size: 34,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Gap(20),
                  Text(
                    _isLoginMode ? 'Welcome back' : 'Create account',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    _isLoginMode
                        ? 'Sign in to report or claim lost & found items.'
                        : 'Join your community to help return lost belongings.',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Gap(24),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Sign In'),
                        icon: Icon(Icons.login_rounded, size: 18),
                      ),
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Sign Up'),
                        icon: Icon(Icons.person_add_alt_1_rounded, size: 18),
                      ),
                    ],
                    selected: {_isLoginMode},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _isLoginMode = selection.first;
                        _formKey.currentState?.reset();
                      });
                    },
                  ),
                  const Gap(24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Please enter your email';
                            if (!v.contains('@') || !v.contains('.')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const Gap(14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: _isLoginMode
                              ? TextInputAction.done
                              : TextInputAction.next,
                          onFieldSubmitted:
                              _isLoginMode ? (_) => _submit() : null,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (!_isLoginMode && value.length < 4) {
                              return 'Password must be at least 4 characters';
                            }
                            return null;
                          },
                        ),
                        if (!_isLoginMode) ...[
                          const Gap(14),
                          TextFormField(
                            controller: _usernameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const Gap(14),
                          TextFormField(
                            controller: _phoneNoController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Gap(24),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isLoginMode ? 'Sign In' : 'Create Account'),
                  ),
                  const Gap(16),
                  if (_isLoginMode)
                    TextButton.icon(
                      onPressed: _fillDemoUser,
                      icon: const Icon(Icons.bolt_rounded, size: 18),
                      label: const Text('Use demo account (omar@gmail.com)'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
