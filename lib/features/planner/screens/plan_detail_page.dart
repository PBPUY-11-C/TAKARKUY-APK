import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';
import 'package:takarkuy_apk/core/widgets/app_snackbar.dart';
import 'package:takarkuy_apk/core/widgets/async_state_view.dart';

import '../data/plan_models.dart';
import '../data/planner_repository.dart';
import '../planner_colors.dart';
import '../planner_format.dart';
import '../providers/plan_detail_provider.dart';
import '../widgets/nutrition_ring.dart';

/// Halaman hasil rencana: ringkasan budget, tab Jadwal/Belanja/Gizi, simpan, dan hapus.
/// Ditutup dengan `Navigator.pop(context, true)` setelah rencana dihapus.
class PlanDetailPage extends StatelessWidget {
  const PlanDetailPage({super.key, required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          PlanDetailProvider(PlannerRepository(context.read<ApiClient?>() ?? ApiClient()), planId: planId)..load(),
      child: const _PlanDetailScaffold(),
    );
  }
}

class _PlanDetailScaffold extends StatelessWidget {
  const _PlanDetailScaffold();

  Future<void> _confirmDelete(BuildContext context, PlanDetailProvider detail) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus rencana ini?'),
        content: const Text('Jadwal dan daftar belanjanya ikut terhapus. Stok Pantry tidak berubah.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: PlannerColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yes != true || !context.mounted) return;
    if (await detail.delete()) {
      if (context.mounted) Navigator.pop(context, true);
    } else if (context.mounted) {
      showAppSnackBar(context, detail.saveError ?? 'Rencana gagal dihapus.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = context.watch<PlanDetailProvider>();
    final plan = detail.plan;
    return Scaffold(
      backgroundColor: PlannerColors.background,
      appBar: AppBar(
        title: Text(plan?.summary.title ?? 'Rencana'),
        actions: [
          if (plan != null) ...[
            Center(child: _StatusChip(draft: plan.summary.isDraft)),
            PopupMenuButton<String>(
              tooltip: 'Pilihan lain',
              onSelected: (_) => _confirmDelete(context, detail),
              itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Hapus rencana'))],
            ),
          ],
        ],
      ),
      body: AsyncStateView(
        loading: detail.loading,
        hasData: plan != null,
        error: detail.error,
        onRetry: detail.load,
        builder: (context) => PlanDetailBody(plan: plan!),
      ),
      bottomNavigationBar: plan == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: PlannerColors.green,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: detail.busy ? null : () => _openSaveSheet(context, detail),
                  child: Text(plan.summary.isDraft ? 'Simpan rencana' : 'Ubah judul & tanggal',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
    );
  }

  Future<void> _openSaveSheet(BuildContext context, PlanDetailProvider detail) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ChangeNotifierProvider.value(value: detail, child: const _SaveSheet()),
    );
    if (saved == true && context.mounted) showAppSnackBar(context, 'Rencana tersimpan.');
  }
}

/// Isi hasil rencana tanpa AppBar, dipakai di HP maupun panel kanan tablet.
class PlanDetailBody extends StatelessWidget {
  const PlanDetailBody({super.key, required this.plan});

  final PlanDetail plan;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 12), child: _BudgetCard(plan: plan)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: const Color(0xFFE9EDF3), borderRadius: BorderRadius.circular(12)),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                boxShadow: const [BoxShadow(color: Color(0x1F172235), blurRadius: 3, offset: Offset(0, 1))],
              ),
              labelColor: PlannerColors.ink,
              unselectedLabelColor: PlannerColors.muted,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: const [Tab(text: 'Jadwal', height: 40), Tab(text: 'Belanja', height: 40), Tab(text: 'Gizi', height: 40)],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [_ScheduleTab(plan: plan), _ShoppingTab(plan: plan), _NutritionTab(plan: plan)],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.draft});

  final bool draft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: draft ? PlannerColors.warnSoft : PlannerColors.greenSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(draft ? 'Draft' : 'Tersimpan',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: draft ? PlannerColors.warn : PlannerColors.greenText,
          )),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.plan});

  final PlanDetail plan;

  @override
  Widget build(BuildContext context) {
    final summary = plan.summary;
    final left = summary.budget - summary.total;
    final within = plan.withinBudget && left >= 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: PlannerColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Total belanja',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: PlannerColors.muted)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: within ? PlannerColors.greenSoft : const Color(0xFFFDECEA),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(within ? 'Dalam budget' : 'Melebihi budget',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: within ? PlannerColors.greenText : PlannerColors.danger,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text(formatRupiah(summary.total),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: PlannerColors.ink)),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('/ ${formatRupiah(summary.budget)}',
                    style: const TextStyle(fontSize: 14, color: PlannerColors.muted)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: summary.budgetUsed.clamp(0, 1).toDouble()),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: PlannerColors.line,
                color: within ? PlannerColors.green : PlannerColors.danger,
                semanticsLabel: 'Budget terpakai',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(left >= 0 ? 'Sisa ${formatRupiah(left)}' : 'Lebih ${formatRupiah(-left)}',
              style: const TextStyle(fontSize: 13, color: PlannerColors.muted)),
        ],
      ),
    );
  }
}

class _ScheduleTab extends StatefulWidget {
  const _ScheduleTab({required this.plan});

  final PlanDetail plan;

  @override
  State<_ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<_ScheduleTab> {
  int _day = 0;

  @override
  Widget build(BuildContext context) {
    final schedule = widget.plan.schedule;
    if (schedule.isEmpty) {
      return const Center(child: Text('Jadwal belum tersedia.', style: TextStyle(color: PlannerColors.muted)));
    }
    final day = schedule[_day.clamp(0, schedule.length - 1)];
    final date = widget.plan.summary.startsOn.add(Duration(days: day.number - 1));
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < schedule.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('Hari ${schedule[i].number}'),
                    selected: i == _day,
                    onSelected: (_) => setState(() => _day = i),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(formatLongDate(date), style: const TextStyle(fontSize: 13, color: PlannerColors.muted)),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Column(
            key: ValueKey(day.number),
            children: [
              for (final meal in day.meals) ...[_MealCard(meal: meal), const SizedBox(height: 10)],
            ],
          ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});

  final PlanMeal meal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: PlannerColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: const Color(0xFFEEF2EE), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.soup_kitchen_outlined, color: Color(0xFF6F7F75)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: PlannerColors.soft, borderRadius: BorderRadius.circular(6)),
                  child: Text(meal.label,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: PlannerColors.ink)),
                ),
                const SizedBox(height: 4),
                Text(meal.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: PlannerColors.ink, height: 1.3)),
                const SizedBox(height: 2),
                Text('${formatRupiah(meal.cost)} · ${meal.calories} kkal/porsi',
                    style: const TextStyle(fontSize: 12, color: PlannerColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingTab extends StatelessWidget {
  const _ShoppingTab({required this.plan});

  final PlanDetail plan;

  String _grams(num quantity) => quantity % 1 == 0 ? '${quantity.toInt()} g' : '${quantity.toStringAsFixed(1)} g';

  @override
  Widget build(BuildContext context) {
    final total = plan.shoppingGroups.fold(0, (sum, group) => sum + group.total);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const Text('Daftar belanja', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: PlannerColors.ink)),
        Text('${plan.itemCount} bahan · ${plan.days} hari', style: const TextStyle(fontSize: 13, color: PlannerColors.muted)),
        const SizedBox(height: 10),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: PlannerColors.line),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (final group in plan.shoppingGroups)
                ExpansionTile(
                  shape: const Border(),
                  title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w700, color: PlannerColors.ink)),
                  subtitle: Text('${group.items.length} bahan', style: const TextStyle(color: PlannerColors.muted)),
                  trailing: Text(formatRupiah(group.total),
                      style: const TextStyle(fontWeight: FontWeight.w700, color: PlannerColors.ink)),
                  children: [
                    for (final item in group.items)
                      ListTile(
                        dense: true,
                        title: Text(item.name),
                        subtitle: Text(_grams(item.quantity)),
                        trailing: Text(formatRupiah(item.netCost)),
                      ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Total', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: PlannerColors.ink)),
                    ),
                    Text(formatRupiah(total),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: PlannerColors.ink)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NutritionTab extends StatelessWidget {
  const _NutritionTab({required this.plan});

  final PlanDetail plan;

  static const _labels = ['Energi', 'Protein', 'Karbohidrat', 'Lemak'];
  static const _units = ['kkal', 'protein', 'karbo', 'lemak'];

  @override
  Widget build(BuildContext context) {
    final nutrition = plan.nutrition;
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          const Text('Gizi per hari', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: PlannerColors.ink)),
          const Text('Dibanding acuan harian yang dipakai web',
              style: TextStyle(fontSize: 13, color: PlannerColors.muted)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: constraints.maxWidth >= 600 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 18,
            crossAxisSpacing: 12,
            childAspectRatio: 0.78,
            children: [
              for (var i = 0; i < 4; i++)
                NutritionRing(
                  label: _labels[i],
                  value: i == 0 ? '${nutrition.values[i]}' : '${nutrition.values[i]} g',
                  unit: _units[i],
                  ratio: nutrition.ratios[i],
                  caption: '${nutrition.percents[i]}% dari ${Nutrition.targets[i]} ${i == 0 ? 'kkal' : 'g'}',
                  color: PlannerColors.rings[i],
                  track: PlannerColors.ringTracks[i],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SaveSheet extends StatefulWidget {
  const _SaveSheet();

  @override
  State<_SaveSheet> createState() => _SaveSheetState();
}

class _SaveSheetState extends State<_SaveSheet> {
  late final PlanDetailProvider _detail = context.read<PlanDetailProvider>();
  late final _title = TextEditingController(text: _detail.plan!.summary.title);
  late DateTime _startsOn = _detail.plan!.summary.startsOn;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _startsOn,
      firstDate: _startsOn.isBefore(today) ? _startsOn : today,
      // Batas yang sama dengan MAX_START_DAYS di apps/planner/services.py.
      lastDate: today.add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _startsOn = picked);
  }

  Future<void> _save() async {
    if (await _detail.save(title: _title.text, startsOn: _startsOn) && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final detail = context.watch<PlanDetailProvider>();
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Simpan rencana', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: PlannerColors.ink)),
          const SizedBox(height: 4),
          const Text('Rencana tersimpan muncul di Rencana Saya dan bisa dibuka lagi di web.',
              style: TextStyle(fontSize: 14, color: PlannerColors.muted)),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            maxLength: PlanDetailProvider.maxTitle,
            decoration: InputDecoration(labelText: 'Judul rencana', errorText: detail.saveError),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text('Mulai ${formatLongDate(_startsOn)}'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: PlannerColors.green, minimumSize: const Size(64, 48)),
                  onPressed: detail.busy ? null : _save,
                  child: detail.busy
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
