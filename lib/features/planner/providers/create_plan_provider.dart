import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';

import '../data/plan_models.dart';
import '../data/planner_repository.dart';

/// State form "Rencana baru" tiga langkah; aturan validasinya sama dengan PlannerForm di web.
class CreatePlanProvider extends ChangeNotifier {
  CreatePlanProvider(this._repo);

  static const mealChoices = [('sarapan', 'Pagi'), ('makan_siang', 'Siang'), ('makan_malam', 'Malam')];
  static const targetChoices = [
    ('seimbang', 'Seimbang'),
    ('tinggi_protein', 'Tinggi protein'),
    ('rendah_kalori', 'Rendah kalori'),
  ];
  static const riceChoices = [
    ('nasi', 'Nasi'),
    ('kentang', 'Kentang'),
    ('ubi', 'Ubi'),
    ('singkong', 'Singkong'),
    ('jagung', 'Jagung'),
    ('no', 'Tanpa'),
  ];
  static const maxBudget = 100000000;
  static const maxExclusions = 10;
  static const lastStep = 2;

  final PlannerRepository _repo;

  int budget = 150000;
  int days = 3;
  int servings = 2;
  final Set<String> mealTypes = {for (final (code, _) in mealChoices) code};
  final Set<String> targets = {'seimbang'};
  String rice = 'nasi';
  final List<String> exclusions = [];

  int step = 0;
  String? stepError;
  bool submitting = false;
  String? submitError;

  /// True setelah server menolak karena masih ada draft; form menunggu persetujuan mengganti.
  bool needsReplaceConfirmation = false;

  PlanInput get input => PlanInput(
        budget: budget,
        days: days,
        servings: servings,
        mealTypes: [for (final (code, _) in mealChoices) if (mealTypes.contains(code)) code],
        targets: [for (final (code, _) in targetChoices) if (targets.contains(code)) code],
        rice: rice,
        excludeIngredients: List.of(exclusions),
      );

  void setBudget(int value) => _update(() => budget = value);

  void changeDays(int delta) => _update(() => days = (days + delta).clamp(1, 7));

  void changeServings(int delta) => _update(() => servings = (servings + delta).clamp(1, 10));

  void toggleMeal(String code) => _update(() => mealTypes.contains(code) ? mealTypes.remove(code) : mealTypes.add(code));

  void toggleTarget(String code) => _update(() => targets.contains(code) ? targets.remove(code) : targets.add(code));

  void setRice(String code) => _update(() => rice = code);

  /// Menambah bahan yang dihindari; mengembalikan pesan error bila ditolak.
  String? addExclusion(String raw) {
    final name = raw.trim();
    if (name.isEmpty) return 'Tulis nama bahan.';
    if (exclusions.length >= maxExclusions) return 'Maksimal $maxExclusions bahan.';
    if (exclusions.any((item) => item.toLowerCase() == name.toLowerCase())) return 'Bahan itu sudah ada.';
    _update(() => exclusions.add(name));
    return null;
  }

  void removeExclusion(String name) => _update(() => exclusions.remove(name));

  /// Pindah ke langkah berikutnya bila langkah sekarang valid.
  bool next() {
    stepError = _validate(step);
    if (stepError == null && step < lastStep) step++;
    notifyListeners();
    return stepError == null;
  }

  void back() => _update(() {
        if (step > 0) step--;
        stepError = null;
      });

  String? _validate(int step) {
    if (step == 0) {
      if (budget < 1) return 'Isi budget minimal Rp 1.';
      if (budget > maxBudget) return 'Maksimal budget Rp 100.000.000.';
    }
    if (step == 1) {
      if (mealTypes.isEmpty) return 'Pilih minimal satu waktu makan.';
      if (targets.isEmpty) return 'Pilih minimal satu target gizi.';
    }
    return null;
  }

  /// Menyusun rencana. `replaceDraft` dipakai setelah pengguna setuju draft lama diganti.
  Future<PlanDetail?> submit({bool replaceDraft = false}) async {
    submitting = true;
    submitError = null;
    notifyListeners();
    try {
      PlanDetail plan;
      if (replaceDraft) {
        final draft = (await _repo.list()).where((plan) => plan.isDraft).firstOrNull;
        plan = await _repo.create(input, replaceDraftId: draft?.id, replaceDraftVersion: draft?.version);
      } else {
        plan = await _repo.create(input);
      }
      needsReplaceConfirmation = false;
      return plan;
    } on ApiException catch (e) {
      if (e.code == 'http_409' && !replaceDraft) {
        needsReplaceConfirmation = true;
      } else {
        submitError = e.message;
      }
      return null;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  void _update(void Function() change) {
    change();
    stepError = null;
    notifyListeners();
  }
}

/// Angka rupiah dari teks seperti "150.000"; teks kosong dianggap 0.
int parseRupiah(String text) => int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

/// Membuang selain angka dan menambahkan titik ribuan saat pengguna mengetik budget.
class RupiahInputFormatter extends TextInputFormatter {
  const RupiahInputFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '').replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final grouped = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) grouped.write('.');
      grouped.write(digits[i]);
    }
    final text = grouped.toString();
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
