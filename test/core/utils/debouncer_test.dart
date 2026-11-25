import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/core/utils/debouncer.dart';

void main() {
  // testWidgets memakai jam palsu, jadi tester.pump(durasi) memajukan waktu tanpa menunggu.
  testWidgets('hanya aksi terakhir yang dijalankan setelah jeda', (tester) async {
    final debouncer = Debouncer(delay: const Duration(milliseconds: 400));
    final queries = <String>[];

    for (final query in ['t', 'te', 'tem', 'tempe']) {
      debouncer.run(() => queries.add(query));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(queries, isEmpty);

    await tester.pump(const Duration(milliseconds: 400));
    expect(queries, ['tempe']);
  });

  testWidgets('dispose membatalkan aksi yang tertunda', (tester) async {
    final debouncer = Debouncer();
    var called = false;
    debouncer.run(() => called = true);
    debouncer.dispose();

    await tester.pump(const Duration(seconds: 1));
    expect(called, isFalse);
  });
}
