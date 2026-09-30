import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../utils/validators.dart';

const _background = Color(0xFFF7FBFB);
const _teal = Color(0xFF0F9B8E);
const _cyan = Color(0xFF18A8E0);
const _ink = Color(0xFF334155);
const _muted = Color(0xFF94A3B8);
const _border = Color(0xFFDCE4EA);

enum _LoginRole { renter, owner }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _LoginRole _selectedRole = _LoginRole.renter;
  bool _obscurePassword = true;

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
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minimumContentHeight = constraints.maxHeight > 52
                ? constraints.maxHeight - 52
                : 0.0;

            return Container(
              key: const Key('login-register'),
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: _background,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: minimumContentHeight,
                        ),
                        child: AutofillGroup(
                          child: Form(
                            key: _formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _BrandHeader(),
                                const SizedBox(height: 28),
                                const _AuthTabs(),
                                const SizedBox(height: 20),
                                const _FieldLabel('Email Kampus / Umum'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  key: const Key('login-email-field'),
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  decoration: _inputDecoration(
                                    hintText: 'nama@email.com',
                                  ),
                                  validator: Validators.email,
                                ),
                                const SizedBox(height: 16),
                                const _FieldLabel('Password'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  key: const Key('login-password-field'),
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  decoration: _inputDecoration(
                                    hintText: 'Masukkan password',
                                    suffixIcon: IconButton(
                                      tooltip: _obscurePassword
                                          ? 'Tampilkan password'
                                          : 'Sembunyikan password',
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: _muted,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  validator: Validators.password,
                                  onFieldSubmitted: (_) => _submit(),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      foregroundColor: _cyan,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 0,
                                      ),
                                      minimumSize: const Size(0, 44),
                                    ),
                                    child: const Text(
                                      'Lupa Password?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                const _FieldLabel('MASUK SEBAGAI ROLE'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _RoleOption(
                                        key: const Key('login-role-renter'),
                                        label: 'Penyewa (Mahasiswa)',
                                        icon: Icons.person_outline_rounded,
                                        selected:
                                            _selectedRole == _LoginRole.renter,
                                        onTap: () => setState(
                                          () =>
                                              _selectedRole = _LoginRole.renter,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _RoleOption(
                                        key: const Key('login-role-owner'),
                                        label: 'Pemilik Kos',
                                        icon: Icons.business_center_outlined,
                                        selected:
                                            _selectedRole == _LoginRole.owner,
                                        onTap: () => setState(
                                          () =>
                                              _selectedRole = _LoginRole.owner,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _GradientSubmitButton(onPressed: _submit),
                                const SizedBox(height: 18),
                                const _DividerLabel(),
                                const SizedBox(height: 18),
                                OutlinedButton(
                                  key: const Key('login-google-button'),
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _ink,
                                    backgroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(48),
                                    side: const BorderSide(color: _border),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'G',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                      Text(
                                        'Google',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const _RegisterPrompt(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: _muted, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _cyan, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_cyan, _teal]),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'SiKos',
              style: TextStyle(
                color: _teal,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Cari Kos Jadi Mudah',
          style: TextStyle(
            color: _muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AuthTabs extends StatelessWidget {
  const _AuthTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Expanded(child: _AuthTab(label: 'Masuk', selected: true)),
          Expanded(child: _AuthTab(label: 'Daftar')),
        ],
      ),
    );
  }
}

class _AuthTab extends StatelessWidget {
  const _AuthTab({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: selected ? Border.all(color: _border) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? _teal : _muted,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _ink,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE4F6FB) : Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: selected ? _cyan : _border),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? _teal : _muted),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? _teal : _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientSubmitButton extends StatelessWidget {
  const _GradientSubmitButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [_cyan, _teal]),
        ),
        child: InkWell(
          key: const Key('login-submit-button'),
          onTap: onPressed,
          child: const SizedBox(
            height: 48,
            child: Center(
              child: Text(
                'Masuk Sekarang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: _border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ATAU MASUK DENGAN',
            style: TextStyle(
              color: _muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: _border)),
      ],
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Belum punya akun?',
          style: TextStyle(color: _muted, fontSize: 12),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: _teal,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: const Size(0, 44),
          ),
          child: const Text(
            'Daftar Akun Baru',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
