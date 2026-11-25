import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/core/utils/optimistic.dart';

void main() {
  test('perubahan tampil dulu, lalu tetap bila server berhasil', () async {
    final items = ['a', 'b'];

    await optimistic(
      apply: () => items.remove('a'),
      rollback: () => items.insert(0, 'a'),
      commit: () async => expect(items, ['b']),
    );

    expect(items, ['b']);
  });

  test('perubahan dibatalkan dan error diteruskan bila server gagal', () async {
    final items = ['a', 'b'];

    await expectLater(
      optimistic(
        apply: () => items.remove('a'),
        rollback: () => items.insert(0, 'a'),
        commit: () async => throw Exception('server gagal'),
      ),
      throwsException,
    );

    expect(items, ['a', 'b']);
  });
}
