import 'package:flutter/material.dart';

import 'package:takarkuy_apk/core/theme/app_colors.dart';

/// Tampilan standar data dari API, urutannya: gagal, memuat, kosong, lalu isi.
/// Saat memuat ulang (`loading` dan `hasData`), isi lama tetap tampil dengan garis progres di atas.
class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.builder,
    this.loading = false,
    this.hasData = false,
    this.error,
    this.onRetry,
    this.empty = false,
    this.emptyMessage = 'Belum ada data.',
  });

  final WidgetBuilder builder;
  final bool loading;
  final bool hasData;
  final String? error;
  final VoidCallback? onRetry;
  final bool empty;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return _Message(
        icon: Icons.cloud_off_outlined,
        message: error!,
        action: onRetry == null
            ? null
            : OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
      );
    }
    if (loading && !hasData) {
      return const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Memuat'),
      );
    }
    if (empty) {
      return _Message(icon: Icons.inbox_outlined, message: emptyMessage);
    }
    return Column(
      children: [
        if (loading) const LinearProgressIndicator(minHeight: 2),
        Expanded(child: Builder(builder: builder)),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.ink),
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
