import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';
import 'package:takarkuy_apk/features/planner/data/planner_repository.dart';
import 'package:takarkuy_apk/features/planner/providers/planner_provider.dart';

import '../planner_fixtures.dart';

/// Server palsu yang jawabannya bisa diganti di tengah tes.
class _Server {
  http.Response Function(http.Request request) reply = (_) => http.Response('[]', 200);
  final requests = <http.Request>[];

  PlannerProvider provider() {
    final client = MockClient((request) async {
      requests.add(request);
      return reply(request);
    });
    return PlannerProvider(PlannerRepository(ApiClient(client: client, baseUrl: 'https://api.test')));
  }
}

http.Response _json(Object body, [int status = 200]) => http.Response(jsonEncode(body), status);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final second = {...summaryJson, 'id': 'b2', 'title': 'Akhir Pekan', 'status': 'saved', 'version': 2};

  test('load mengisi daftar dan melewati status memuat', () async {
    final server = _Server()..reply = (_) => _json([summaryJson, second]);
    final provider = server.provider();
    final states = <bool>[];
    provider.addListener(() => states.add(provider.loading));

    await provider.load();

    expect(states, [true, false]);
    expect(provider.plans.map((p) => p.title), ['Rencana Makan Saya', 'Akhir Pekan']);
    expect(provider.error, isNull);
    expect(provider.offline, isFalse);
  });

  test('load gagal tanpa cache menampilkan pesan error', () async {
    final server = _Server()..reply = (_) => throw http.ClientException('offline');
    final provider = server.provider();

    await provider.load();

    expect(provider.plans, isEmpty);
    expect(provider.error, contains('Tidak bisa terhubung'));
  });

  test('load gagal setelah pernah berhasil memakai cache dan menandai offline', () async {
    final server = _Server()..reply = (_) => _json([summaryJson]);
    await server.provider().load();

    server.reply = (_) => throw http.ClientException('offline');
    final provider = server.provider();
    await provider.load();

    expect(provider.plans.single.title, 'Rencana Makan Saya');
    expect(provider.offline, isTrue);
    expect(provider.error, isNull);
  });

  test('pencarian menyaring judul tanpa membedakan huruf besar kecil', () async {
    final server = _Server()..reply = (_) => _json([summaryJson, second]);
    final provider = server.provider();
    await provider.load();

    provider.search('akhir');

    expect(provider.visiblePlans.map((p) => p.title), ['Akhir Pekan']);
    provider.search('');
    expect(provider.visiblePlans.length, 2);
  });

  testWidgets('hapus langsung menghilangkan kartu, lalu dikirim ke server setelah jeda', (tester) async {
    final server = _Server()..reply = (_) => _json([summaryJson, second]);
    final provider = server.provider();
    await tester.runAsync(provider.load);
    server.reply = (_) => _json({'deleted': true});

    provider.deleteWithUndo(provider.plans.first);
    expect(provider.plans.map((p) => p.id), ['b2']);
    expect(server.requests.where((r) => r.method == 'POST'), isEmpty);

    await tester.pump(PlannerProvider.undoWindow);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));

    final delete = server.requests.singleWhere((r) => r.method == 'POST');
    expect(delete.url.path, '/api/planner/plans/${summaryJson['id']}/delete/');
    expect(jsonDecode(delete.body), {'version': 1});
  });

  testWidgets('Batal mengembalikan kartu ke posisinya dan tidak mengirim apa pun', (tester) async {
    final server = _Server()..reply = (_) => _json([summaryJson, second]);
    final provider = server.provider();
    await tester.runAsync(provider.load);

    final plan = provider.plans.first;
    provider.deleteWithUndo(plan);
    provider.undoDelete(plan.id);
    await tester.pump(PlannerProvider.undoWindow * 2);

    expect(provider.plans.map((p) => p.id), [plan.id, 'b2']);
    expect(server.requests.where((r) => r.method == 'POST'), isEmpty);
  });

  testWidgets('hapus yang ditolak server mengembalikan kartu dan memberi pesan', (tester) async {
    final server = _Server()..reply = (_) => _json([summaryJson, second]);
    final provider = server.provider();
    await tester.runAsync(provider.load);
    server.reply = (_) => _json({'error': 'Rencana sudah berubah.', 'code': 'error'}, 409);

    provider.deleteWithUndo(provider.plans.first);
    await tester.pump(PlannerProvider.undoWindow);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));

    expect(provider.plans.map((p) => p.id), [summaryJson['id'], 'b2']);
    expect(provider.actionError, 'Rencana sudah berubah.');
  });
}
