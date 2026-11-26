import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';

import '../data/plan_models.dart';
import '../data/planner_repository.dart';

/// State daftar Rencana Saya: memuat, gagal, cache offline, pencarian, dan hapus dengan Batal.
class PlannerProvider extends ChangeNotifier {
  PlannerProvider(this._repo);

  /// Lama tombol "Batal" tersedia sebelum hapus benar-benar dikirim ke server.
  static const undoWindow = Duration(seconds: 4);
  static const _cacheKey = 'takarkuy.planner.plans';

  final PlannerRepository _repo;
  final _pending = <String, ({PlanSummary plan, int index, Timer timer})>{};
  List<PlanSummary> _plans = [];
  String _query = '';
  bool _disposed = false;

  bool loading = false;
  String? error;

  /// True bila daftar diambil dari cache karena server tidak bisa dihubungi.
  bool offline = false;

  /// Pesan gagal dari aksi terakhir (mis. hapus ditolak server), untuk ditampilkan lalu dihapus.
  String? actionError;

  List<PlanSummary> get plans => List.unmodifiable(_plans);

  List<PlanSummary> get visiblePlans {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return plans;
    return [for (final plan in _plans) if (plan.title.toLowerCase().contains(query)) plan];
  }

  Future<void> load() async {
    loading = true;
    error = null;
    _notify();
    try {
      _plans = await _repo.list();
      offline = false;
      await _writeCache();
    } on ApiException catch (e) {
      final cached = e.code == 'network' ? await _readCache() : null;
      if (cached != null) {
        _plans = cached;
        offline = true;
      } else {
        error = e.message;
      }
    }
    loading = false;
    _notify();
  }

  void search(String query) {
    _query = query;
    _notify();
  }

  /// Optimistic delete: kartu hilang sekarang, server baru dihubungi setelah [undoWindow].
  void deleteWithUndo(PlanSummary plan) {
    final index = _plans.indexWhere((p) => p.id == plan.id);
    if (index < 0) return;
    _plans.removeAt(index);
    _pending[plan.id] = (plan: plan, index: index, timer: Timer(undoWindow, () => _commitDelete(plan.id)));
    _notify();
  }

  void undoDelete(String id) {
    final pending = _pending.remove(id);
    if (pending == null) return;
    pending.timer.cancel();
    _restore(pending.plan, pending.index);
    _notify();
  }

  void clearActionError() => actionError = null;

  Future<void> _commitDelete(String id) async {
    final pending = _pending.remove(id);
    if (pending == null) return;
    try {
      await _repo.delete(pending.plan.id, version: pending.plan.version);
      await _writeCache();
    } on ApiException catch (e) {
      _restore(pending.plan, pending.index);
      actionError = e.message;
      _notify();
    }
  }

  void _restore(PlanSummary plan, int index) => _plans.insert(index.clamp(0, _plans.length), plan);

  Future<List<PlanSummary>?> _readCache() async {
    final raw = (await SharedPreferences.getInstance()).getString(_cacheKey);
    if (raw == null) return null;
    return [for (final row in jsonDecode(raw) as List) PlanSummary.fromJson(row as Map<String, dynamic>)];
  }

  Future<void> _writeCache() async => (await SharedPreferences.getInstance())
      .setString(_cacheKey, jsonEncode([for (final plan in _plans) plan.toJson()]));

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    // Hapus yang masih menunggu tetap dikirim agar tidak hilang saat halaman ditutup.
    for (final id in _pending.keys.toList()) {
      _pending[id]!.timer.cancel();
      _commitDelete(id);
    }
    super.dispose();
  }
}
