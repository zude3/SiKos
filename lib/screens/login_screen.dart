import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final frameWidth = constraints.constrainWidth(402);
            final frameHeight = constraints.constrainHeight(844);

            return Center(
              child: Container(
                key: const Key('login-register'),
                width: frameWidth,
                height: frameHeight,
                color: const Color(0xFFF7FBFB),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, contentConstraints) {
                          final minimumContentHeight =
                              contentConstraints.maxHeight > 48
                              ? contentConstraints.maxHeight - 48
                              : 0.0;

                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: minimumContentHeight,
                              ),
                              child: Center(
                                child: AutofillGroup(
                                  child: Form(
                                    key: _formKey,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Align(
                                          child: Container(
                                            width: 72,
                                            height: 72,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  colorScheme.primaryContainer,
                                            ),
                                            child: Icon(
                                              Icons.home_work_outlined,
                                              size: 36,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          'Masuk ke SiKos',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Temukan kos yang nyaman di sekitar kampusmu.',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                        const SizedBox(height: 32),
                                        TextFormField(
                                          key: const Key('login-email-field'),
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.email,
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: 'Email',
                                            prefixIcon: Icon(
                                              Icons.email_outlined,
                                            ),
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: Validators.email,
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          key: const Key(
                                            'login-password-field',
                                          ),
                                          controller: _passwordController,
                                          obscureText: true,
                                          textInputAction: TextInputAction.done,
                                          autofillHints: const [
                                            AutofillHints.password,
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: 'Password',
                                            prefixIcon: Icon(
                                              Icons.lock_outline,
                                            ),
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: Validators.password,
                                          onFieldSubmitted: (_) => _submit(),
                                        ),
                                        const SizedBox(height: 24),
                                        FilledButton(
                                          key: const Key('login-submit-button'),
                                          onPressed: _submit,
                                          style: FilledButton.styleFrom(
                                            minimumSize: const Size.fromHeight(
                                              48,
                                            ),
                                          ),
                                          child: const Text('Masuk'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
