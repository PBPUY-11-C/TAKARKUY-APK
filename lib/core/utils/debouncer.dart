import 'dart:async';

import 'package:flutter/foundation.dart';

/// Menunda aksi sampai pengguna berhenti mengetik; tiap panggilan baru membatalkan yang lama.
/// Contoh: `onChanged: (q) => _debouncer.run(() => provider.search(q))`.
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Panggil di dispose() milik State agar aksi tidak jalan setelah halaman ditutup.
  void dispose() => _timer?.cancel();
}
