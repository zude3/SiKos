import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../utils/validators.dart';

const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF64748B);
const _teal = Color(0xFF0D9488);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // (1) key untuk Form dan controller untuk setiap field
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // (2) buang controller saat layar ditutup
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // (3) dijalankan saat tombol Masuk ditekan
  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return; // ada isian yang salah -> berhenti

    // Isian benar -> pindah ke Home, Login dibuang dari stack
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            // (4) bungkus field dengan Form
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo bulat bergradasi, sama seperti avatar di Home
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF0EA5E9), _teal],
                        ),
                      ),
                      child: const Icon(
                        Icons.home_work_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Masuk ke SiKos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Temukan kos impianmu dengan mudah',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, fontSize: 13),
                  ),
                  const SizedBox(height: 32),

                  // (5) TextField diganti TextFormField + validator
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 24),

                  // (6) tombol memanggil _submit
                  FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
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
  }
}