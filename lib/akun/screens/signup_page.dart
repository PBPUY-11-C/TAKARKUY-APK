import 'package:flutter/material.dart';

import '../auth_layout.dart';
import '../auth_theme.dart';

import '../signup_validation.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _acceptedTerms = false;
  bool _showTermsError = false;
  bool _showPassword = false;
  bool _showConfirmation = false;
  Brightness? _brightnessOverride;
  bool _themeInitialized = false;

  Brightness get _brightness =>
      _brightnessOverride ?? Theme.of(context).brightness;

  ThemeData get _theme => authTheme(Theme.of(context), _brightness);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_themeInitialized) {
      _brightnessOverride = authBrightnessFromRoute(context);
      _themeInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _password.addListener(_refreshRequirements);
    _confirmation.addListener(_refreshRequirements);
  }

  void _refreshRequirements() => setState(() {});

  @override
  void dispose() {
    for (final controller in [
      _name,
      _username,
      _email,
      _password,
      _confirmation,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final valid = _formKey.currentState!.validate();
    setState(() => _showTermsError = !_acceptedTerms);
    if (!valid || !_acceptedTerms) return;
    FocusScope.of(context).unfocus();
    _showNotice('Pendaftaran belum tersedia', 'Silakan coba lagi nanti.');
  }

  void _goToLogin() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map &&
        arguments['fromLogin'] == true &&
        Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/login',
        arguments: {'brightness': _brightness},
      );
    }
  }

  void _showNotice(String title, String message) {
    final colors = AuthColors(_brightness);
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
            title,
            style: TextStyle(color: colors.text, fontSize: 20),
          ),
          content: Text(message, style: TextStyle(color: colors.muted)),
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
    final colors = AuthColors(_brightness);
    return AuthLayout(
      theme: _theme,
      colors: colors,
      backLabel: 'Kembali',
      onBack: () => Navigator.maybePop(context),
      onToggleTheme: () => setState(
        () => _brightnessOverride = colors.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      title: 'Daftar Akun',
      description: 'Mulai atur porsi dan belanja dapur lebih hemat.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SignupField(
              id: 'name',
              controller: _name,
              validator: SignupValidation.name,
              autofillHints: const [AutofillHints.name],
              label: 'Nama Lengkap',
              hint: 'Nama lengkap kamu',
              icon: Icons.badge_outlined,
              colors: colors,
            ),
            _SignupField(
              id: 'username',
              controller: _username,
              validator: SignupValidation.username,
              autofillHints: const [AutofillHints.newUsername],
              label: 'Username',
              hint: 'username_kamu',
              icon: Icons.alternate_email,
              colors: colors,
            ),
            _SignupField(
              id: 'email',
              controller: _email,
              validator: SignupValidation.email,
              autofillHints: const [AutofillHints.email],
              label: 'Email',
              hint: 'nama@email.com',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              colors: colors,
            ),
            _SignupField(
              id: 'password',
              controller: _password,
              validator: SignupValidation.password,
              onToggle: () => setState(() => _showPassword = !_showPassword),
              autofillHints: const [AutofillHints.newPassword],
              label: 'Kata Sandi',
              hint: 'Minimal 8 karakter',
              icon: Icons.lock_outline,
              obscure: !_showPassword,
              colors: colors,
            ),
            _SignupField(
              id: 'confirmation',
              controller: _confirmation,
              validator: (value) =>
                  SignupValidation.confirmation(value, _password.text),
              onToggle: () =>
                  setState(() => _showConfirmation = !_showConfirmation),
              onSubmitted: (_) => _submit(),
              autofillHints: const [AutofillHints.newPassword],
              label: 'Konfirmasi Kata Sandi',
              hint: 'Ulangi kata sandi',
              icon: Icons.verified_user_outlined,
              obscure: !_showConfirmation,
              colors: colors,
            ),
            Wrap(
              spacing: 14,
              runSpacing: 10,
              children: [
                for (final entry in {
                  'Min 8': _password.text.length >= 8,
                  'Kapital': SignupValidation.hasUppercase(_password.text),
                  'Angka': SignupValidation.hasNumber(_password.text),
                  'Simbol': SignupValidation.hasSymbol(_password.text),
                  'Cocok':
                      _confirmation.text.isNotEmpty &&
                      _confirmation.text == _password.text,
                }.entries)
                  _Requirement(
                    label: entry.key,
                    satisfied: entry.value,
                    colors: colors,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  semanticLabel: 'Setuju dengan Syarat & Ketentuan TAKARKUY',
                  activeColor: colors.accent,
                  checkColor: colors.actionText,
                  onChanged: (value) => setState(() {
                    _acceptedTerms = value ?? false;
                    _showTermsError = !_acceptedTerms;
                  }),
                  side: BorderSide(color: colors.muted),
                ),
                Expanded(
                  child: TextButton(
                    key: const ValueKey('signup-terms'),
                    onPressed: () => _showNotice(
                      'Syarat & Ketentuan',
                      'Dokumen akan tersedia sebelum pendaftaran dibuka.',
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      minimumSize: const Size(0, 48),
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: 'Saya setuju dengan ',
                        style: TextStyle(color: colors.muted, fontSize: 12),
                        children: [
                          TextSpan(
                            text: 'Syarat & Ketentuan',
                            style: TextStyle(
                              color: colors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: ' TAKARKUY.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_showTermsError)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Setujui syarat terlebih dahulu.',
                  style: TextStyle(color: colors.error, fontSize: 12),
                ),
              ),
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
                      'DaftarKuy',
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
      footerLabel: 'Sudah punya akun?',
      footerAction: 'MasukKuy',
      onFooterAction: _goToLogin,
    );
  }
}

class _SignupField extends StatelessWidget {
  const _SignupField({
    required this.id,
    required this.label,
    required this.hint,
    required this.icon,
    required this.colors,
    this.keyboardType,
    this.obscure = false,
    this.controller,
    this.validator,
    this.autofillHints,
    this.onToggle,
    this.onSubmitted,
  });

  final String id, label, hint;
  final IconData icon;
  final AuthColors colors;
  final TextInputType? keyboardType;
  final bool obscure;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final VoidCallback? onToggle;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
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
          TextFormField(
            key: ValueKey('signup-$id'),
            controller: controller,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            autofillHints: autofillHints,
            autocorrect: id == 'name',
            enableSuggestions: id != 'password' && id != 'confirmation',
            textCapitalization: id == 'name'
                ? TextCapitalization.words
                : TextCapitalization.none,
            textInputAction: id == 'confirmation'
                ? TextInputAction.done
                : TextInputAction.next,
            onFieldSubmitted: onSubmitted,
            keyboardType: keyboardType,
            obscureText: obscure,
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
              hintStyle: TextStyle(color: colors.muted, fontSize: 13),
              prefixIcon: Icon(icon, size: 18, color: colors.muted),
              suffixIcon: onToggle != null
                  ? IconButton(
                      onPressed: onToggle,
                      tooltip:
                          '${obscure ? 'Tampilkan' : 'Sembunyikan'} $label',
                      icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 19,
                        color: colors.accent,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: colors.field,
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
        ],
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement({
    required this.label,
    required this.colors,
    required this.satisfied,
  });

  final String label;
  final AuthColors colors;
  final bool satisfied;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: ${satisfied ? 'terpenuhi' : 'belum terpenuhi'}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            satisfied
                ? Icons.check_circle_outline
                : Icons.radio_button_unchecked,
            size: 13,
            color: satisfied ? colors.accent : colors.muted,
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: colors.muted)),
        ],
      ),
    );
  }
}
