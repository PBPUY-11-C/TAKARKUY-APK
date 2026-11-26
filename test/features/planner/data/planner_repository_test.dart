import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';
import 'package:takarkuy_apk/features/planner/data/plan_models.dart';
import 'package:takarkuy_apk/features/planner/data/planner_repository.dart';

import '../planner_fixtures.dart';

void main() {
  late List<http.Request> requests;

  PlannerRepository repoReplying(Object body, {int status = 200}) {
    requests = [];
    final client = MockClient((request) async {
      requests.add(request);
      return http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});
    });
    return PlannerRepository(ApiClient(client: client, baseUrl: 'https://api.test')..token = 'tok');
  }

  test('list memanggil daftar rencana dengan token', () async {
    final plans = await repoReplying([summaryJson]).list();

    expect(plans.single.title, 'Rencana Makan Saya');
    expect(requests.single.method, 'GET');
    expect(requests.single.url.toString(), 'https://api.test/api/planner/plans/');
    expect(requests.single.headers['Authorization'], 'Token tok');
  });

  test('detail membuka satu rencana', () async {
    final plan = await repoReplying(detailJson).detail('abc');

    expect(plan.schedule, isNotEmpty);
    expect(requests.single.url.path, '/api/planner/plans/abc/');
  });

  test('create mengirim input dan izin mengganti draft lama', () async {
    const input = PlanInput(
      budget: 150000, days: 3, servings: 2,
      mealTypes: ['sarapan'], targets: ['seimbang'], rice: 'nasi',
    );
    await repoReplying(detailJson, status: 201)
        .create(input, replaceDraftId: 'old', replaceDraftVersion: 4);

    expect(requests.single.method, 'POST');
    expect(requests.single.url.path, '/api/planner/plans/');
    expect(jsonDecode(requests.single.body), {
      ...input.toJson(),
      'replace_draft': true,
      'replace_draft_id': 'old',
      'replace_draft_version': 4,
    });
  });

  test('save mengirim versi, judul, dan tanggal mulai', () async {
    await repoReplying(detailJson).save('abc', version: 2, title: 'Minggu ini', startsOn: DateTime(2026, 11, 30));

    expect(requests.single.url.path, '/api/planner/plans/abc/save/');
    expect(jsonDecode(requests.single.body), {'version': 2, 'title': 'Minggu ini', 'starts_on': '2026-11-30'});
  });

  test('delete mengirim versi rencana', () async {
    await repoReplying({'deleted': true}).delete('abc', version: 3);

    expect(requests.single.url.path, '/api/planner/plans/abc/delete/');
    expect(jsonDecode(requests.single.body), {'version': 3});
  });

  test('error dari server diteruskan sebagai ApiException dengan kodenya', () async {
    final repo = repoReplying({'error': 'Setujui penggantian draft.', 'code': 'error'}, status: 409);

    expect(
      () => repo.list(),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Setujui penggantian draft.')),
    );
  });
}
