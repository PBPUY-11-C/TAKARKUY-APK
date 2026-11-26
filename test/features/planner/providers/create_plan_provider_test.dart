import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';
import 'package:takarkuy_apk/features/planner/data/planner_repository.dart';
import 'package:takarkuy_apk/features/planner/providers/create_plan_provider.dart';

import '../planner_fixtures.dart';

class _Server {
  http.Response Function(http.Request request) reply = (_) => http.Response(jsonEncode(detailJson), 201);
  final requests = <http.Request>[];

  CreatePlanProvider provider() => CreatePlanProvider(PlannerRepository(ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          return reply(request);
        }),
        baseUrl: 'https://api.test',
      )));
}

void main() {
  test('isian awal sama dengan form web', () {
    final form = _Server().provider();

    expect(form.budget, 150000);
    expect(form.days, 3);
    expect(form.servings, 2);
    expect(form.mealTypes, {'sarapan', 'makan_siang', 'makan_malam'});
    expect(form.targets, {'seimbang'});
    expect(form.rice, 'nasi');
    expect(form.input.perPersonPerDay, 25000);
    expect(form.step, 0);
  });

  test('hari dibatasi 1 sampai 7 dan orang 1 sampai 10', () {
    final form = _Server().provider();

    for (var i = 0; i < 10; i++) {
      form.changeDays(1);
      form.changeServings(1);
    }
    expect((form.days, form.servings), (7, 10));
    for (var i = 0; i < 12; i++) {
      form.changeDays(-1);
      form.changeServings(-1);
    }
    expect((form.days, form.servings), (1, 1));
  });

  test('langkah budget menolak nominal di luar Rp 1 sampai Rp 100.000.000', () {
    final form = _Server().provider();

    form.setBudget(0);
    expect(form.next(), isFalse);
    expect(form.stepError, 'Isi budget minimal Rp 1.');
    form.setBudget(100000001);
    expect(form.next(), isFalse);
    expect(form.stepError, 'Maksimal budget Rp 100.000.000.');
    form.setBudget(150000);
    expect(form.next(), isTrue);
    expect(form.step, 1);
  });

  test('langkah preferensi wajib punya waktu makan dan target gizi', () {
    final form = _Server().provider()..next();

    form.toggleTarget('seimbang');
    expect(form.next(), isFalse);
    expect(form.stepError, 'Pilih minimal satu target gizi.');
    form.toggleTarget('tinggi_protein');
    for (final meal in ['sarapan', 'makan_siang', 'makan_malam']) {
      form.toggleMeal(meal);
    }
    expect(form.next(), isFalse);
    expect(form.stepError, 'Pilih minimal satu waktu makan.');
    form.toggleMeal('makan_malam');
    expect(form.next(), isTrue);
    expect(form.step, 2);
  });

  test('bahan dihindari dirapikan, tidak dobel, dan maksimal 10', () {
    final form = _Server().provider();

    expect(form.addExclusion('  Udang '), isNull);
    expect(form.addExclusion('udang'), 'Bahan itu sudah ada.');
    expect(form.addExclusion('   '), 'Tulis nama bahan.');
    for (var i = 0; i < 9; i++) {
      form.addExclusion('bahan $i');
    }
    expect(form.addExclusion('satu lagi'), 'Maksimal 10 bahan.');
    expect(form.exclusions.first, 'Udang');
    form.removeExclusion('Udang');
    expect(form.exclusions.length, 9);
  });

  test('submit mengirim isian dan mengembalikan rencana', () async {
    final server = _Server();
    final form = server.provider()..addExclusion('udang');

    final plan = await form.submit();

    expect(plan!.summary.title, 'Rencana Makan Saya');
    expect(jsonDecode(server.requests.single.body), {
      'budget': '150000',
      'days': 3,
      'servings': 2,
      'meal_types': ['sarapan', 'makan_siang', 'makan_malam'],
      'targets': ['seimbang'],
      'rice': 'nasi',
      'exclude_ingredients': 'udang',
    });
  });

  test('budget kurang (400) menyimpan pesan server tanpa rencana', () async {
    final server = _Server()..reply = (_) => http.Response(jsonEncode({'error': 'Budget belum cukup untuk menu ini.'}), 400);
    final form = server.provider();

    expect(await form.submit(), isNull);
    expect(form.submitError, 'Budget belum cukup untuk menu ini.');
    expect(form.needsReplaceConfirmation, isFalse);
  });

  test('draft lama (409) meminta persetujuan, lalu mengganti draft itu', () async {
    final server = _Server();
    var posts = 0;
    server.reply = (request) {
      if (request.method == 'GET') return http.Response(jsonEncode([summaryJson]), 200);
      posts++;
      if (posts == 1) return http.Response(jsonEncode({'error': 'Setujui penggantian draft.'}), 409);
      return http.Response(jsonEncode(detailJson), 201);
    };
    final form = server.provider();

    expect(await form.submit(), isNull);
    expect(form.needsReplaceConfirmation, isTrue);

    final plan = await form.submit(replaceDraft: true);

    expect(plan, isNotNull);
    final body = jsonDecode(server.requests.last.body) as Map;
    expect(body['replace_draft'], isTrue);
    expect(body['replace_draft_id'], summaryJson['id']);
    expect(body['replace_draft_version'], summaryJson['version']);
    expect(form.needsReplaceConfirmation, isFalse);
  });

  test('format input rupiah menambah titik ribuan dan membuang selain angka', () {
    const formatter = RupiahInputFormatter();
    TextEditingValue type(String text) =>
        formatter.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text));

    expect(type('150000').text, '150.000');
    expect(type('Rp 1a2b3').text, '123');
    expect(type('').text, '');
    expect(parseRupiah('150.000'), 150000);
    expect(parseRupiah(''), 0);
  });
}
