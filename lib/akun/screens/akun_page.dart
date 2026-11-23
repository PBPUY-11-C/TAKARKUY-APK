import 'package:flutter/material.dart';

import '../auth_error_banner.dart';
import '../auth_layout.dart';
import '../auth_theme.dart';

/// Halaman masuk Modul 3, dikembangkan dari kerangka Akun yang sudah ada.
class AkunPage extends StatefulWidget {
  const AkunPage({super.key});

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  final _formKey = GlobalKey<FormState>();
  final _errorSummaryKey = GlobalKey();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;
  bool _rememberMe = false;
  bool _submitted = false;
  bool _themeInitialized = false;
  Brightness? _brightnessOverride;

  Brightness get _brightness =>
      _brightnessOverride ?? Theme.of(context).brightness;
  ThemeData get _theme => authTheme(Theme.of(context), _brightness);
  AuthColors get _colors => AuthColors(_brightness);

  String? _identifierError(String? value) =>
      value == null || value.trim().isEmpty ? 'Isi email atau username.' : null;

  String? _passwordError(String? value) =>
      value == null || value.isEmpty ? 'Isi kata sandi.' : null;

  bool get _hasErrors =>
      _identifierError(_identifier.text) != null ||
      _passwordError(_password.text) != null;

  void _onFormChanged() {
    if (_submitted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_themeInitialized) {
      _brightnessOverride = authBrightnessFromRoute(context);
      _themeInitialized = true;
    }
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
    final valid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (!valid) {
      revealAuthError(_errorSummaryKey);
      return;
    }
    final colors = _colors;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Theme(
        data: _theme,
        child: AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: colors.border, width: 1.5),
          ),
          title: Text(
            'Login belum tersedia',
            style: TextStyle(color: colors.text, fontSize: 20),
          ),
          content: Text(
            'Silakan coba lagi nanti.',
            style: TextStyle(color: colors.muted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(foregroundColor: colors.accent),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    return AuthLayout(
      theme: _theme,
      colors: colors,
      backLabel: 'Kembali ke beranda',
      onBack: () => Navigator.popUntil(context, (route) => route.isFirst),
      onToggleTheme: () => setState(
        () => _brightnessOverride = colors.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      title: 'Selamat Datang',
      description: 'Masuk ke akunmu untuk lanjut memasak.',
      form: Form(
        key: _formKey,
        onChanged: _onFormChanged,
        autovalidateMode: _submitted
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_submitted && _hasErrors) ...[
              AuthErrorBanner(
                key: _errorSummaryKey,
                id: 'login',
                title: 'Periksa isian login',
                colors: colors,
              ),
              const SizedBox(height: 18),
            ],
            _LoginField(
              id: 'identifier',
              controller: _identifier,
              validator: _identifierError,
              showErrors: _submitted,
              label: 'Email atau Username',
              hint: 'contoh@email.com atau username',
              icon: Icons.person_outline,
              colors: colors,
            ),
            const SizedBox(height: 14),
            _LoginField(
              id: 'password',
              showPassword: _showPassword,
              onToggle: () => setState(() => _showPassword = !_showPassword),
              controller: _password,
              validator: _passwordError,
              showErrors: _submitted,
              onSubmitted: (_) => _submit(),
              label: 'Kata Sandi',
              hint: 'Masukkan kata sandi',
              icon: Icons.lock_outline,
              colors: colors,
            ),
            InkWell(
              onTap: () => setState(() => _rememberMe = !_rememberMe),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) =>
                        setState(() => _rememberMe = value ?? false),
                    activeColor: colors.accent,
                    checkColor: colors.actionText,
                    side: BorderSide(color: colors.muted, width: 1.5),
                  ),
                  Expanded(
                    child: Text(
                      'Ingat saya',
                      style: TextStyle(color: colors.text, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.actionText,
                minimumSize: const Size.fromHeight(48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'MasukKuy',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      footerLabel: 'Belum punya akun?',
      footerAction: 'DaftarKuy',
      onFooterAction: () => Navigator.pushNamed(
        context,
        '/signup',
        arguments: {'fromLogin': true, 'brightness': _brightness},
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.id,
    required this.label,
    required this.hint,
    required this.icon,
    required this.colors,
    this.controller,
    this.validator,
    this.onSubmitted,
    this.showPassword = false,
    this.showErrors = false,
    this.onToggle,
  });

  final String id, label, hint;
  final IconData icon;
  final AuthColors colors;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final bool showPassword;
  final bool showErrors;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final invalid = showErrors && validator?.call(controller?.text) != null;
    final password = id == 'password';
    final visibilityLabel = showPassword
        ? 'Sembunyikan kata sandi'
        : 'Tampilkan kata sandi';
    final visibilityIcon = showPassword
        ? Icons.visibility_off_outlined
        : Icons.visibility_outlined;
    final compact =
        MediaQuery.sizeOf(context).width < 360 ||
        MediaQuery.textScalerOf(context).scale(12) > 15;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.text,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Semantics(
          label: label,
          child: TextFormField(
            key: ValueKey('login-$id'),
            controller: controller,
            validator: validator,
            onFieldSubmitted: onSubmitted,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            obscureText: password && !showPassword,
            keyboardType: password
                ? TextInputType.visiblePassword
                : TextInputType.emailAddress,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: password
                ? TextInputAction.done
                : TextInputAction.next,
            autofillHints: [
              password ? AutofillHints.password : AutofillHints.username,
            ],
            style: TextStyle(color: colors.text, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              errorMaxLines: 3,
              errorStyle: TextStyle(color: colors.error),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.error, width: 1.5),
              ),
              hintStyle: TextStyle(color: colors.muted, fontSize: 12),
              prefixIcon: Icon(
                icon,
                size: 18,
                color: invalid ? colors.error : colors.muted,
              ),
              suffixIcon: !password
                  ? null
                  : compact
                  ? IconButton(
                      onPressed: onToggle,
                      tooltip: visibilityLabel,
                      icon: Icon(
                        visibilityIcon,
                        color: colors.accent,
                        size: 18,
                      ),
                    )
                  : Tooltip(
                      message: visibilityLabel,
                      child: TextButton.icon(
                        onPressed: onToggle,
                        icon: Icon(visibilityIcon, size: 17),
                        label: Text(showPassword ? 'Sembunyikan' : 'Tampilkan'),
                        style: TextButton.styleFrom(
                          foregroundColor: colors.accent,
                          textStyle: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontSize: 11),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(48, 48),
                        ),
                      ),
                    ),
              filled: true,
              fillColor: invalid ? colors.errorSurface : colors.field,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.accent, width: 1.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
