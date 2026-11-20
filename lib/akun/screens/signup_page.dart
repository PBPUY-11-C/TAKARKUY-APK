import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = _SignupColors(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back, size: 20),
                        label: const Text('Kembali'),
                        style: TextButton.styleFrom(
                          foregroundColor: colors.muted,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(80, 48),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colors.field,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Icon(
                                Icons.soup_kitchen_outlined,
                                size: 20,
                                color: colors.accent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'TAKARKUY',
                                  style: TextStyle(
                                    color: colors.text,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Daftar Akun',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mulai atur porsi dan belanja dapur lebih hemat.',
                    style: TextStyle(color: colors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.border),
                    ),
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SignupField(
                            id: 'name',
                            label: 'Nama Lengkap',
                            hint: 'Nama lengkap kamu',
                            icon: Icons.badge_outlined,
                            colors: colors,
                          ),
                          _SignupField(
                            id: 'username',
                            label: 'Username',
                            hint: 'username_kamu',
                            icon: Icons.alternate_email,
                            colors: colors,
                          ),
                          _SignupField(
                            id: 'email',
                            label: 'Email',
                            hint: 'nama@email.com',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            colors: colors,
                          ),
                          _SignupField(
                            id: 'password',
                            label: 'Kata Sandi',
                            hint: 'Minimal 8 karakter',
                            icon: Icons.lock_outline,
                            obscure: true,
                            colors: colors,
                          ),
                          _SignupField(
                            id: 'confirmation',
                            label: 'Konfirmasi Kata Sandi',
                            hint: 'Ulangi kata sandi',
                            icon: Icons.verified_user_outlined,
                            obscure: true,
                            colors: colors,
                          ),
                          Wrap(
                            spacing: 14,
                            runSpacing: 10,
                            children: [
                              for (final label in [
                                'Min 8',
                                'Kapital',
                                'Angka',
                                'Simbol',
                                'Cocok',
                              ])
                                _Requirement(label: label, colors: colors),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: false,
                                onChanged: (_) {},
                                side: BorderSide(color: colors.muted),
                              ),
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'Saya setuju dengan ',
                                      style: TextStyle(
                                        color: colors.muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        foregroundColor: colors.accent,
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 32),
                                      ),
                                      child: const Text('Syarat & Ketentuan'),
                                    ),
                                    Text(
                                      ' TAKARKUY.',
                                      style: TextStyle(
                                        color: colors.muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.accent,
                              foregroundColor: colors.actionText,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'DaftarKuy',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun?',
                          style: TextStyle(color: colors.muted),
                        ),
                        TextButton(
                          onPressed: () => Navigator.maybePop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: colors.accent,
                          ),
                          child: const Text(
                            'MasukKuy',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
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

class _SignupField extends StatelessWidget {
  const _SignupField({
    required this.id,
    required this.label,
    required this.hint,
    required this.icon,
    required this.colors,
    this.keyboardType,
    this.obscure = false,
  });

  final String id, label, hint;
  final IconData icon;
  final _SignupColors colors;
  final TextInputType? keyboardType;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
            keyboardType: keyboardType,
            obscureText: obscure,
            style: TextStyle(color: colors.text, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: colors.muted, fontSize: 13),
              prefixIcon: Icon(icon, size: 18, color: colors.muted),
              suffixIcon: obscure
                  ? IconButton(
                      onPressed: () {},
                      tooltip: 'Tampilkan $label',
                      icon: Icon(
                        Icons.visibility_outlined,
                        size: 19,
                        color: colors.muted,
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
  const _Requirement({required this.label, required this.colors});

  final String label;
  final _SignupColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.radio_button_unchecked, size: 13, color: colors.muted),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: colors.muted)),
      ],
    );
  }
}

class _SignupColors {
  const _SignupColors(this.brightness);
  final Brightness brightness;
  bool get dark => brightness == Brightness.dark;
  Color get background =>
      dark ? const Color(0xFF0F1713) : const Color(0xFFF2F8F4);
  Color get card => dark ? const Color(0xFF14251C) : Colors.white;
  Color get field => dark ? const Color(0xFF1B2D23) : const Color(0xFFE6F5EC);
  Color get border => dark ? const Color(0xFF294334) : const Color(0xFFDCEBE2);
  Color get text => dark ? const Color(0xFFF2F7F4) : const Color(0xFF10251C);
  Color get muted => dark ? const Color(0xFFA3BBAE) : const Color(0xFF5A6F64);
  Color get accent => dark ? const Color(0xFFD4F45A) : const Color(0xFF0F3D2E);
  Color get actionText => dark ? const Color(0xFF10251C) : Colors.white;
}
