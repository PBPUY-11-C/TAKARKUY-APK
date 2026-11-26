import 'package:flutter/foundation.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';

import '../data/plan_models.dart';
import '../data/planner_repository.dart';

/// State halaman hasil rencana: memuat detail, menyimpan judul dan tanggal, serta menghapus.
class PlanDetailProvider extends ChangeNotifier {
  PlanDetailProvider(this._repo, {required this.planId});

  static const maxTitle = 100;

  final PlannerRepository _repo;

  /// Bisa berganti setelah draft disimpan, karena server membalas rencana tersimpan dengan id baru.
  String planId;

  PlanDetail? plan;
  bool loading = false;
  String? error;
  bool busy = false;

  /// Pesan gagal dari simpan atau hapus, ditampilkan di lembar simpan atau SnackBar.
  String? saveError;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      plan = await _repo.detail(planId);
    } on ApiException catch (e) {
      error = e.message;
    }
    loading = false;
    notifyListeners();
  }

  /// Menyimpan draft menjadi rencana (server bisa membalas rencana dengan id baru), atau mengubah
  /// judul dan tanggal rencana tersimpan. Judul dirapikan seperti PlanMetadataForm di web.
  Future<bool> save({required String title, DateTime? startsOn}) async {
    final current = plan;
    final clean = title.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).join(' ');
    saveError = clean.isEmpty
        ? 'Isi judul rencana.'
        : clean.length > maxTitle
            ? 'Judul maksimal $maxTitle karakter.'
            : null;
    if (current == null || saveError != null) {
      notifyListeners();
      return false;
    }
    return _run(() async {
      plan = await _repo.save(current.summary.id, version: current.summary.version, title: clean, startsOn: startsOn);
      planId = plan!.summary.id;
    });
  }

  Future<bool> delete() async {
    final current = plan;
    if (current == null) return false;
    return _run(() => _repo.delete(current.summary.id, version: current.summary.version));
  }

  Future<bool> _run(Future<void> Function() action) async {
    busy = true;
    saveError = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on ApiException catch (e) {
      saveError = e.message;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
