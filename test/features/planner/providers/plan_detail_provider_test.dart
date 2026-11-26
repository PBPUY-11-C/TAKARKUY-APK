import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';
import 'package:takarkuy_apk/features/planner/data/planner_repository.dart';
import 'package:takarkuy_apk/features/planner/providers/plan_detail_provider.dart';

import '../planner_fixtures.dart';

final savedDetail = {...detailJson, 'id': 'saved-1', 'status': 'saved', 'title': 'Minggu ini', 'version': 1};

class _Server {
  http.Response Function(http.Request request) reply = (_) => http.Response(jsonEncode(detailJson), 200);
  final requests = <http.Request>[];

  PlanDetailProvider provider() => PlanDetailProvider(
        PlannerRepository(ApiClient(
          client: MockClient((request) async {
            requests.add(request);
            return reply(request);
          }),
          baseUrl: 'https://api.test',
        )),
        planId: 'f485e609-87f8-4ac3-bc2d-c0f5d3c51c76',
      );
}

void main() {
  test('load membuka detail rencana', () async {
    final detail = _Server().provider();

    await detail.load();

    expect(detail.plan!.summary.title, 'Rencana Makan Saya');
    expect(detail.error, isNull);
    expect(detail.loading, isFalse);
  });

  test('load gagal menyimpan pesan error', () async {
    final server = _Server()..reply = (_) => throw http.ClientException('offline');
    final detail = server.provider();

    await detail.load();

    expect(detail.plan, isNull);
    expect(detail.error, contains('Tidak bisa terhubung'));
  });

  test('save mengirim versi, judul, tanggal, lalu memakai rencana tersimpan dari server', () async {
    final server = _Server();
    final detail = server.provider();
    await detail.load();
    server.reply = (_) => http.Response(jsonEncode(savedDetail), 200);

    final ok = await detail.save(title: '  Minggu ini ', startsOn: DateTime(2026, 11, 30));

    expect(ok, isTrue);
    expect(server.requests.last.url.path, '/api/planner/plans/f485e609-87f8-4ac3-bc2d-c0f5d3c51c76/save/');
    expect(jsonDecode(server.requests.last.body), {'version': 1, 'title': 'Minggu ini', 'starts_on': '2026-11-30'});
    expect(detail.plan!.summary.id, 'saved-1');
    expect(detail.plan!.summary.isDraft, isFalse);
  });

  test('save menolak judul kosong tanpa memanggil server', () async {
    final server = _Server();
    final detail = server.provider();
    await detail.load();

    expect(await detail.save(title: '   ', startsOn: DateTime(2026, 11, 30)), isFalse);
    expect(detail.saveError, 'Isi judul rencana.');
    expect(server.requests.length, 1);
  });

  test('save yang ditolak server menyimpan pesannya', () async {
    final server = _Server();
    final detail = server.provider();
    await detail.load();
    server.reply = (_) => http.Response(jsonEncode({'error': 'Rencana sudah berubah di tab/perangkat lain.'}), 409);

    expect(await detail.save(title: 'Baru', startsOn: DateTime(2026, 11, 30)), isFalse);
    expect(detail.saveError, 'Rencana sudah berubah di tab/perangkat lain.');
  });

  test('delete mengirim versi rencana', () async {
    final server = _Server();
    final detail = server.provider();
    await detail.load();
    server.reply = (_) => http.Response(jsonEncode({'deleted': true}), 200);

    expect(await detail.delete(), isTrue);
    expect(server.requests.last.url.path, '/api/planner/plans/f485e609-87f8-4ac3-bc2d-c0f5d3c51c76/delete/');
    expect(jsonDecode(server.requests.last.body), {'version': 1});
  });
}
