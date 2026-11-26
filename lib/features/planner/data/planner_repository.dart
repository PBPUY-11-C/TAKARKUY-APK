import 'package:takarkuy_apk/core/api/api_client.dart';

import 'plan_models.dart';

/// Pintu Planner ke API Django `/api/planner/`; semua kegagalan dilempar sebagai ApiException.
class PlannerRepository {
  PlannerRepository(this._api);

  final ApiClient _api;

  static const _base = '/api/planner/plans/';

  Future<List<PlanSummary>> list() async {
    final rows = await _api.get(_base) as List;
    return [for (final row in rows) PlanSummary.fromJson(row as Map<String, dynamic>)];
  }

  Future<PlanDetail> detail(String id) async =>
      PlanDetail.fromJson(await _api.get('$_base$id/') as Map<String, dynamic>);

  /// Menyusun rencana baru sebagai draft. Bila sudah ada draft, server menolak (409) kecuali
  /// `replaceDraftId` dan `replaceDraftVersion` draft lama dikirim sebagai persetujuan mengganti.
  Future<PlanDetail> create(PlanInput input, {String? replaceDraftId, int? replaceDraftVersion}) async {
    final body = {
      ...input.toJson(),
      if (replaceDraftId != null) ...{
        'replace_draft': true,
        'replace_draft_id': replaceDraftId,
        'replace_draft_version': replaceDraftVersion,
      },
    };
    return PlanDetail.fromJson(await _api.post(_base, body) as Map<String, dynamic>);
  }

  /// Menyimpan draft menjadi rencana, atau mengubah judul dan tanggal rencana tersimpan.
  Future<PlanDetail> save(String id, {required int version, required String title, DateTime? startsOn}) async {
    final body = {'version': version, 'title': title, if (startsOn != null) 'starts_on': apiDate(startsOn)};
    return PlanDetail.fromJson(await _api.post('$_base$id/save/', body) as Map<String, dynamic>);
  }

  Future<void> delete(String id, {required int version}) =>
      _api.post('$_base$id/delete/', {'version': version});
}
