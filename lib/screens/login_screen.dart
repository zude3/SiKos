import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../utils/validators.dart';

const _pageBackground = Color(0xFFF7FBFB);
const _brandTeal = Color(0xFF0D9488);
const _brandBlue = Color(0xFF0EA5E9);
const _ink = Color(0xFF26364A);
const _muted = Color(0xFF8292A5);
const _fieldLine = Color(0xFFDDE6EE);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isRegisterMode = false;
  bool _isPasswordVisible = false;
  bool _isTenantSelected = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isRegisterMode) {
      _showMessage('Form pendaftaran valid.');
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 42,
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBrand(),
                    const SizedBox(height: 24),
                    _buildModeSelector(),
                    const SizedBox(height: 18),
                    if (_isRegisterMode) ...[
                      _fieldLabel('Nama Lengkap'),
                      const SizedBox(height: 6),
                      _textField(
                        controller: _nameController,
                        hintText: 'Nama kamu',
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            Validators.requiredField(value, fieldName: 'Nama'),
                      ),
                      const SizedBox(height: 14),
                    ],
                    _fieldLabel('Email Kampus / Umum'),
                    const SizedBox(height: 6),
                    _textField(
                      controller: _emailController,
                      hintText: 'nama@email.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 14),
                    _fieldLabel('Password'),
                    const SizedBox(height: 6),
                    _textField(
                      controller: _passwordController,
                      hintText: 'Masukkan password',
                      obscureText: !_isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      validator: Validators.password,
                      onSubmitted: (_) => _submit(),
                      suffixIcon: IconButton(
                        tooltip: _isPasswordVisible
                            ? 'Sembunyikan password'
                            : 'Tampilkan password',
                        onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _muted,
                          size: 20,
                        ),
                      ),
                    ),
                    if (!_isRegisterMode) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showMessage(
                            'Fitur lupa password belum tersedia.',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: _brandBlue,
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRoleSelector(),
                    ] else
                      const SizedBox(height: 20),
                    const SizedBox(height: 16),
                    _buildPrimaryButton(),
                    if (!_isRegisterMode) ...[
                      const SizedBox(height: 20),
                      _buildDividerLabel(),
                      const SizedBox(height: 16),
                      _buildGoogleButton(),
                    ],
                    const SizedBox(height: 32),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_brandBlue, _brandTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.home_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'SiKos',
              style: TextStyle(
                color: _brandTeal,
                fontSize: 27,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Cari Kos Jadi Mudah',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E9F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _ModeTab(
            label: 'Masuk',
            selected: !_isRegisterMode,
            onTap: () => setState(() => _isRegisterMode = false),
          ),
          _ModeTab(
            label: 'Daftar',
            selected: _isRegisterMode,
            onTap: () => setState(() => _isRegisterMode = true),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) => Text(
    label,
    style: const TextStyle(
      color: _ink,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      style: const TextStyle(color: _ink, fontSize: 12),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: _muted, fontSize: 12),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 13,
        ),
        suffixIcon: suffixIcon,
        suffixIconConstraints: const BoxConstraints(minWidth: 44),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _fieldLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brandBlue, width: 1.3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MASUK SEBAGAI ROLE',
          style: TextStyle(
            color: _muted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _RoleOption(
                icon: Icons.person_outline,
                label: 'Penyewa (Mahasiswa)',
                selected: _isTenantSelected,
                onTap: () => setState(() => _isTenantSelected = true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RoleOption(
                icon: Icons.business_center_outlined,
                label: 'Pemilik Kos',
                selected: !_isTenantSelected,
                onTap: () => setState(() => _isTenantSelected = false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_brandBlue, _brandTeal],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(13),
          boxShadow: const [
            BoxShadow(
              color: Color(0x260D9488),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          child: Text(
            _isRegisterMode ? 'Daftar Sekarang' : 'Masuk Sekarang',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _buildDividerLabel() => const Row(
    children: [
      Expanded(child: Divider(color: _fieldLine, height: 1)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          'ATAU MASUK DENGAN',
          style: TextStyle(color: _muted, fontSize: 9),
        ),
      ),
      Expanded(child: Divider(color: _fieldLine, height: 1)),
    ],
  );

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: () => _showMessage('Login Google belum tersedia.'),
        icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
        label: const Text('Google'),
        style: OutlinedButton.styleFrom(
          foregroundColor: _ink,
          backgroundColor: Colors.white,
          side: const BorderSide(color: _fieldLine),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          _isRegisterMode ? 'Sudah punya akun? ' : 'Belum punya akun? ',
          style: const TextStyle(color: _muted, fontSize: 11),
        ),
        TextButton(
          onPressed: () => setState(() => _isRegisterMode = !_isRegisterMode),
          style: TextButton.styleFrom(
            foregroundColor: _brandTeal,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _isRegisterMode ? 'Masuk' : 'Daftar Akun Baru',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? _brandTeal : _muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _brandTeal : _muted;
    return SizedBox(
      height: 38,
      child: Material(
        color: selected ? const Color(0xFFE0F5FA) : Colors.white,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: selected ? _brandBlue : _fieldLine),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17, color: color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
