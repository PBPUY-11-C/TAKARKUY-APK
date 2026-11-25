import 'package:flutter/material.dart';

import 'auth_theme.dart';

/// Kerangka bersama agar navigasi dan formulir masuk/daftar tetap seragam.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.theme,
    required this.colors,
    required this.backLabel,
    required this.onBack,
    required this.onToggleTheme,
    required this.title,
    required this.description,
    required this.form,
    required this.footerLabel,
    required this.footerAction,
    required this.onFooterAction,
  });

  final ThemeData theme;
  final AuthColors colors;
  final String backLabel, title, description, footerLabel, footerAction;
  final VoidCallback onBack, onToggleTheme, onFooterAction;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: Scaffold(
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
                            onPressed: onBack,
                            icon: const Icon(Icons.arrow_back, size: 18),
                            label: Text(backLabel),
                            style: TextButton.styleFrom(
                              foregroundColor: colors.accent,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 48),
                              textStyle: theme.textTheme.labelLarge?.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: colors.dark
                              ? 'Gunakan mode terang'
                              : 'Gunakan mode gelap',
                          onPressed: onToggleTheme,
                          style: IconButton.styleFrom(
                            minimumSize: const Size(48, 48),
                            tapTargetSize: MaterialTapTargetSize.padded,
                          ),
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
                                  color: colors.soft,
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
                            title,
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
                            description,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.muted, fontSize: 13),
                          ),
                          const SizedBox(height: 28),
                          form,
                          const SizedBox(height: 14),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                footerLabel,
                                style: TextStyle(
                                  color: colors.muted,
                                  fontSize: 12,
                                ),
                              ),
                              TextButton(
                                onPressed: onFooterAction,
                                style: TextButton.styleFrom(
                                  foregroundColor: colors.accent,
                                ),
                                child: Text(
                                  footerAction,
                                  style: const TextStyle(
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
      ),
    );
  }
}
