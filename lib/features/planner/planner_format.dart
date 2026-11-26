/// Format angka dan tanggal Planner, sama dengan tampilan web (mis. "Rp 133.500", "25 Nov 2026").
library;

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
const _weekdays = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

String formatRupiah(int amount) {
  final digits = amount.abs().toString();
  final grouped = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) grouped.write('.');
    grouped.write(digits[i]);
  }
  return '${amount < 0 ? '-' : ''}Rp $grouped';
}

String formatShortDate(DateTime date) => '${date.day} ${_months[date.month - 1]} ${date.year}';

/// Contoh: "Rabu, 25 Nov 2026".
String formatLongDate(DateTime date) => '${_weekdays[date.weekday - 1]}, ${formatShortDate(date)}';
