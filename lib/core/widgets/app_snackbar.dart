import 'package:flutter/material.dart';

import 'package:takarkuy_apk/core/theme/app_colors.dart';

/// SnackBar seragam: pesan biasa atau error (merah), dengan tombol aksi opsional seperti "Batal".
/// Pesan sebelumnya langsung diganti agar tidak menumpuk.
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool error = false,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.danger : AppColors.ink,
        action: actionLabel == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                textColor: AppColors.lime,
                onPressed: onAction ?? () {},
              ),
      ),
    );
}
