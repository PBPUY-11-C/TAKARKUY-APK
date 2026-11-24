import 'package:flutter/foundation.dart';

/// Optimistic update: `apply` mengubah tampilan langsung, `commit` mengirim ke server, dan bila
/// server gagal `rollback` mengembalikan tampilan lalu error diteruskan agar bisa ditampilkan.
Future<void> optimistic({
  required VoidCallback apply,
  required VoidCallback rollback,
  required Future<void> Function() commit,
}) async {
  apply();
  try {
    await commit();
  } catch (_) {
    rollback();
    rethrow;
  }
}
