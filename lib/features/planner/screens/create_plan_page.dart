import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';

import '../data/planner_repository.dart';
import '../planner_colors.dart';
import '../planner_format.dart';
import '../providers/create_plan_provider.dart';

/// Form "Rencana baru" tiga langkah: budget, preferensi, lalu ringkasan sebelum disusun.
/// Ditutup dengan `Navigator.pop(context, planDetail)` setelah rencana berhasil dibuat.
class CreatePlanPage extends StatelessWidget {
  const CreatePlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreatePlanProvider(PlannerRepository(context.read<ApiClient?>() ?? ApiClient())),
      child: const _CreatePlanView(),
    );
  }
}

class _CreatePlanView extends StatefulWidget {
  const _CreatePlanView();

  @override
  State<_CreatePlanView> createState() => _CreatePlanViewState();
}

class _CreatePlanViewState extends State<_CreatePlanView> {
  final _budget = TextEditingController(text: '150.000');
  final _exclusion = TextEditingController();
  String? _exclusionError;

  @override
  void dispose() {
    _budget.dispose();
    _exclusion.dispose();
    super.dispose();
  }

  void _setBudget(CreatePlanProvider form, int value) {
    _budget.value = const RupiahInputFormatter().formatEditUpdate(_budget.value, TextEditingValue(text: '$value'));
    form.setBudget(value);
  }

  void _addExclusion(CreatePlanProvider form) {
    setState(() => _exclusionError = form.addExclusion(_exclusion.text));
    if (_exclusionError == null) _exclusion.clear();
  }

  Future<void> _submit(CreatePlanProvider form) async {
    var plan = await form.submit();
    if (!mounted) return;
    if (plan == null && form.needsReplaceConfirmation) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ganti draft lama?'),
          content: const Text(
            'Masih ada draft yang belum disimpan. Draft itu akan diganti dengan rencana baru ini.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ganti draft')),
          ],
        ),
      );
      if (replace != true || !mounted) return;
      plan = await form.submit(replaceDraft: true);
      if (!mounted) return;
    }
    if (plan != null) Navigator.pop(context, plan);
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<CreatePlanProvider>();
    return PopScope(
      canPop: form.step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) form.back();
      },
      child: Scaffold(
        backgroundColor: PlannerColors.background,
        appBar: AppBar(
          title: const Text('Rencana baru'),
          leading: IconButton(
            tooltip: form.step == 0 ? 'Tutup' : 'Kembali',
            icon: Icon(form.step == 0 ? Icons.close : Icons.arrow_back),
            onPressed: () => form.step == 0 ? Navigator.pop(context) : form.back(),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepIndicator(step: form.step),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0.04, 0), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                ),
                child: SingleChildScrollView(
                  key: ValueKey(form.step),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  child: switch (form.step) {
                    0 => _BudgetStep(form: form, controller: _budget, onQuickPick: (value) => _setBudget(form, value)),
                    1 => _PreferenceStep(
                        form: form,
                        exclusion: _exclusion,
                        exclusionError: _exclusionError,
                        onAddExclusion: () => _addExclusion(form),
                      ),
                    _ => _SummaryStep(form: form),
                  },
                ),
              ),
            ),
            if (form.stepError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(form.stepError!,
                    style: const TextStyle(color: PlannerColors.danger, fontWeight: FontWeight.w600)),
              ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: PlannerColors.green,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: form.submitting
                      ? null
                      : () => form.step < CreatePlanProvider.lastStep ? form.next() : _submit(form),
                  child: form.submitting
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text(form.step < CreatePlanProvider.lastStep ? 'Lanjut' : 'Buat rencana',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final int step;

  static const _labels = ['1 Budget', '2 Preferensi', '3 Ringkasan'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          for (var i = 0; i < _labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Semantics(
                selected: i == step,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= step ? PlannerColors.green : PlannerColors.line,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(_labels[i],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: i == step ? FontWeight.w800 : FontWeight.w600,
                          color: i <= step ? PlannerColors.greenText : PlannerColors.muted,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

const _label = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PlannerColors.ink);
const _hint = TextStyle(fontSize: 12, color: PlannerColors.muted);

class _BudgetStep extends StatelessWidget {
  const _BudgetStep({required this.form, required this.controller, required this.onQuickPick});

  final CreatePlanProvider form;
  final TextEditingController controller;
  final ValueChanged<int> onQuickPick;

  static const _quick = [('100rb', 100000), ('150rb', 150000), ('350rb', 350000)];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Budget', style: _label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: const [RupiahInputFormatter()],
          onChanged: (text) => form.setBudget(parseRupiah(text)),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: PlannerColors.ink),
          decoration: const InputDecoration(prefixText: 'Rp  ', hintText: '150.000'),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            for (final (label, value) in _quick)
              ChoiceChip(
                label: Text(label),
                selected: form.budget == value,
                onSelected: (_) => onQuickPick(value),
              ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Rp 1 sampai Rp 100.000.000, tanpa koma atau sen.', style: _hint),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _Stepper(
                label: 'Hari',
                value: form.days,
                hint: '1 sampai 7 hari',
                subject: 'hari',
                onChange: form.changeDays,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Stepper(
                label: 'Orang',
                value: form.servings,
                hint: '1 sampai 10 orang',
                subject: 'orang',
                onChange: form.changeServings,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF0F3D2E), borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              const Expanded(
                child: Text('Budget per orang per hari', style: TextStyle(color: Color(0xFFCFE0D6), fontSize: 13)),
              ),
              Text(
                formatRupiah(form.input.perPersonPerDay).replaceFirst('Rp ', 'Rp'),
                style: const TextStyle(color: Color(0xFFD4F45A), fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.hint,
    required this.subject,
    required this.onChange,
  });

  final String label;
  final int value;
  final String hint;
  final String subject;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _label),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: PlannerColors.field),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(tooltip: 'Kurangi $subject', onPressed: () => onChange(-1), icon: const Icon(Icons.remove)),
              Expanded(
                child: Text('$value',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: PlannerColors.ink)),
              ),
              IconButton(tooltip: 'Tambah $subject', onPressed: () => onChange(1), icon: const Icon(Icons.add)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(hint, style: _hint),
      ],
    );
  }
}

class _PreferenceStep extends StatelessWidget {
  const _PreferenceStep({
    required this.form,
    required this.exclusion,
    required this.exclusionError,
    required this.onAddExclusion,
  });

  final CreatePlanProvider form;
  final TextEditingController exclusion;
  final String? exclusionError;
  final VoidCallback onAddExclusion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Waktu makan', style: _label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (code, label) in CreatePlanProvider.mealChoices)
              FilterChip(
                label: Text(label),
                selected: form.mealTypes.contains(code),
                onSelected: (_) => form.toggleMeal(code),
              ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Target gizi', style: _label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (code, label) in CreatePlanProvider.targetChoices)
              FilterChip(
                label: Text(label),
                selected: form.targets.contains(code),
                onSelected: (_) => form.toggleTarget(code),
              ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Karbohidrat', style: _label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (code, label) in CreatePlanProvider.riceChoices)
              ChoiceChip(label: Text(label), selected: form.rice == code, onSelected: (_) => form.setRice(code)),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Bahan yang dihindari (opsional)', style: _label),
        const SizedBox(height: 8),
        TextField(
          controller: exclusion,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onAddExclusion(),
          decoration: InputDecoration(
            hintText: 'Ketik bahan, lalu Enter',
            errorText: exclusionError,
            suffixIcon: IconButton(tooltip: 'Tambah bahan', onPressed: onAddExclusion, icon: const Icon(Icons.add)),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final name in form.exclusions)
              InputChip(label: Text(name), onDeleted: () => form.removeExclusion(name), deleteButtonTooltipMessage: 'Hapus $name'),
          ],
        ),
        const SizedBox(height: 6),
        const Text('Maksimal 10 bahan. Alergi dan preferensi halal diambil dari profil Akun.', style: _hint),
      ],
    );
  }
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({required this.form});

  final CreatePlanProvider form;

  String _labels(List<(String, String)> choices, Iterable<String> selected) =>
      [for (final (code, label) in choices) if (selected.contains(code)) label].join(', ');

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Budget', formatRupiah(form.budget)),
      ('Durasi', '${form.days} hari · ${form.servings} orang'),
      ('Waktu makan', _labels(CreatePlanProvider.mealChoices, form.mealTypes)),
      ('Target gizi', _labels(CreatePlanProvider.targetChoices, form.targets)),
      ('Karbohidrat', _labels(CreatePlanProvider.riceChoices, [form.rice])),
      ('Dihindari', form.exclusions.isEmpty ? 'Tidak ada' : form.exclusions.join(', ')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Periksa sebelum disusun',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: PlannerColors.ink)),
        const SizedBox(height: 14),
        if (form.submitError != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: PlannerColors.warnSoft, borderRadius: BorderRadius.circular(14)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: PlannerColors.warn),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(form.submitError!,
                      style: const TextStyle(color: PlannerColors.warn, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: PlannerColors.line),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++)
                Container(
                  constraints: const BoxConstraints(minHeight: 52),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    border: i == rows.length - 1
                        ? null
                        : const Border(bottom: BorderSide(color: Color(0xFFEEF2F6))),
                  ),
                  child: Row(
                    children: [
                      Text(rows[i].$1, style: const TextStyle(fontSize: 14, color: PlannerColors.muted)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(rows[i].$2,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PlannerColors.ink)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: PlannerColors.greenSoft, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              const Expanded(child: Text('Per orang per hari', style: TextStyle(color: PlannerColors.greenText))),
              Text(formatRupiah(form.input.perPersonPerDay).replaceFirst('Rp ', 'Rp'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: PlannerColors.greenText)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Hasilnya disimpan sebagai draft dulu. Kalau masih ada draft lama, kamu akan ditanya apakah draft itu boleh diganti.',
          style: TextStyle(fontSize: 13, color: PlannerColors.muted, height: 1.5),
        ),
      ],
    );
  }
}
