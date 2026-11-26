import 'package:flutter/material.dart';

import 'auth_theme.dart';

/// Ringkasan singkat; rincian kesalahan tetap berada di kolom terkait.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({
    super.key,
    required this.id,
    required this.title,
    required this.colors,
  });

  final String id, title;
  final AuthColors colors;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: ValueKey('$id-error-summary'),
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.errorSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.error.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(Icons.error_outline, size: 20, color: colors.error),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Perbaiki bagian yang ditandai.',
                    style: TextStyle(color: colors.error, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menampilkan ringkasan setelah formulir dan pesan error selesai dibangun.
void revealAuthError(GlobalKey key) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = key.currentContext;
    if (context == null || !context.mounted) return;
    Scrollable.ensureVisible(
      context,
      alignment: 0.1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  });
}
