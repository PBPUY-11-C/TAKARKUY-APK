import 'package:flutter/material.dart';

/// Halaman masuk Modul 3, dikembangkan dari kerangka Akun yang sudah ada.
class AkunPage extends StatelessWidget {
  const AkunPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = _LoginColors(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () => Navigator.popUntil(
                            context,
                            (route) => route.isFirst,
                          ),
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Kembali ke beranda'),
                          style: TextButton.styleFrom(
                            foregroundColor: colors.accent,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 48),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: colors.dark
                            ? 'Gunakan mode terang'
                            : 'Gunakan mode gelap',
                        onPressed: () {},
                        icon: Icon(
                          colors.dark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          color: colors.muted,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.border),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F3D2E)
                              .withValues(alpha: colors.dark ? 0.18 : 0.06),
                          blurRadius: 28,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colors.field,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF007452),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.soup_kitchen_outlined,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'TAKARKUY',
                                        style: TextStyle(
                                          color: colors.text,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        'HEMAT & NIKMAT',
                                        style: TextStyle(
                                          color: colors.muted,
                                          fontSize: 8,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Selamat Datang',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Masuk ke akunmu untuk lanjut memasak.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.muted, fontSize: 13),
                        ),
                        const SizedBox(height: 28),
                        Form(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _LoginField(
                                id: 'identifier',
                                label: 'Email atau Username',
                                hint: 'contoh@email.com atau username',
                                icon: Icons.person_outline,
                                colors: colors,
                              ),
                              const SizedBox(height: 14),
                              _LoginField(
                                id: 'password',
                                label: 'Kata Sandi',
                                hint: 'Masukkan kata sandi',
                                icon: Icons.lock_outline,
                                colors: colors,
                              ),
                              InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(8),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: false,
                                      onChanged: (_) {},
                                      activeColor: colors.accent,
                                      checkColor: colors.actionText,
                                      side: BorderSide(
                                        color: colors.border,
                                        width: 1.5,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Ingat saya',
                                        style: TextStyle(
                                          color: colors.text,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              FilledButton(
                                onPressed: () {},
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
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Belum punya akun?',
                              style: TextStyle(
                                color: colors.muted,
                                fontSize: 12,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/signup',
                                arguments: const {'fromLogin': true},
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: colors.accent,
                              ),
                              child: const Text(
                                'DaftarKuy',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
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

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.id,
    required this.label,
    required this.hint,
    required this.icon,
    required this.colors,
  });

  final String id, label, hint;
  final IconData icon;
  final _LoginColors colors;

  @override
  Widget build(BuildContext context) {
    final password = id == 'password';
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
            obscureText: password,
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
              hintStyle: TextStyle(color: colors.muted, fontSize: 12),
              prefixIcon: Icon(icon, size: 18, color: colors.muted),
              suffixIcon: !password
                  ? null
                  : compact
                  ? IconButton(
                      onPressed: () {},
                      tooltip: 'Tampilkan kata sandi',
                      icon: Icon(
                        Icons.visibility_outlined,
                        color: colors.accent,
                        size: 18,
                      ),
                    )
                  : Tooltip(
                      message: 'Tampilkan kata sandi',
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility_outlined, size: 17),
                        label: const Text('Tampilkan'),
                        style: TextButton.styleFrom(
                          foregroundColor: colors.accent,
                          textStyle: const TextStyle(fontSize: 11),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(48, 48),
                        ),
                      ),
                    ),
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
        ),
      ],
    );
  }
}

class _LoginColors {
  const _LoginColors(this.brightness);
  final Brightness brightness;
  bool get dark => brightness == Brightness.dark;
  Color get background =>
      dark ? const Color(0xFF0F1713) : const Color(0xFFE9FFF4);
  Color get card => dark ? const Color(0xFF14251C) : Colors.white;
  Color get field => dark ? const Color(0xFF1B2D23) : const Color(0xFFF3F8F5);
  Color get border => dark ? const Color(0xFF294334) : const Color(0xFFDCEBE2);
  Color get text => dark ? const Color(0xFFF2F7F4) : const Color(0xFF10251C);
  Color get muted => dark ? const Color(0xFFA3BBAE) : const Color(0xFF5A6F64);
  Color get accent => dark ? const Color(0xFFD4F45A) : const Color(0xFF007452);
  Color get actionText => dark ? const Color(0xFF10251C) : Colors.white;
  Color get error => dark ? const Color(0xFFF29D95) : const Color(0xFFB42318);
}
