import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:takarkuy_apk/core/api/api_client.dart';
import 'package:takarkuy_apk/core/router/app_router.dart';
import 'package:takarkuy_apk/core/utils/debouncer.dart';
import 'package:takarkuy_apk/core/widgets/app_snackbar.dart';
import 'package:takarkuy_apk/core/widgets/async_state_view.dart';

import 'data/plan_models.dart';
import 'data/planner_repository.dart';
import 'planner_colors.dart';
import 'providers/planner_provider.dart';
import 'screens/create_plan_page.dart';
import 'screens/plan_detail_page.dart';
import 'widgets/plan_card.dart';

/// Halaman Meal Planner (Modul 1): daftar Rencana Saya dari API.
class PlannerPage extends StatelessWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // ApiClient bisa tidak ada saat halaman dibuka dari layar yang dites sendirian.
      create: (context) => PlannerProvider(
        PlannerRepository(context.read<ApiClient?>() ?? ApiClient()),
      )..load(),
      child: const _PlannerView(),
    );
  }
}

class _PlannerView extends StatefulWidget {
  const _PlannerView();

  @override
  State<_PlannerView> createState() => _PlannerViewState();
}

class _PlannerViewState extends State<_PlannerView> {
  /// Mulai lebar ini (tablet atau browser lebar) daftar dan hasil tampil berdampingan.
  static const _wideBreakpoint = 840.0;

  final _debouncer = Debouncer();
  bool _wide = false;

  /// Rencana yang terbuka di panel kanan saat tampilan lebar.
  String? _selected;

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  /// Membuka form rencana baru; rencana yang berhasil dibuat langsung dibuka di halaman hasil.
  Future<void> _create(PlannerProvider planner) async {
    final router = GoRouter.maybeOf(context);
    final plan = router != null
        ? await router.push<PlanDetail>(AppRoutes.plannerNew)
        : await Navigator.push<PlanDetail>(
            context,
            MaterialPageRoute(builder: (_) => const CreatePlanPage()),
          );
    if (plan == null || !mounted) return;
    await planner.load();
    if (mounted) await _open(planner, plan.summary.id);
  }

  /// Membuka hasil rencana, lalu memuat ulang daftar karena judul, status, atau keberadaannya bisa berubah.
  /// Di tampilan lebar, hasil dibuka di panel kanan tanpa pindah halaman.
  Future<void> _open(PlannerProvider planner, String id) async {
    if (_wide) {
      setState(() => _selected = id);
      return;
    }
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      await router.push<bool>(AppRoutes.plannerDetail(id));
    } else {
      await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => PlanDetailPage(planId: id)),
      );
    }
    if (mounted) await planner.load();
  }

  void _delete(PlannerProvider planner, PlanSummary plan) {
    planner.deleteWithUndo(plan);
    showAppSnackBar(
      context,
      'Rencana dihapus.',
      actionLabel: 'Batal',
      onAction: () => planner.undoDelete(plan.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();
    final actionError = planner.actionError;
    if (actionError != null) {
      planner.clearActionError();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showAppSnackBar(context, actionError, error: true);
      });
    }
    final plans = planner.visiblePlans;
    return Scaffold(
      backgroundColor: PlannerColors.background,
      appBar: AppBar(title: const Text('Meal Planner')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(planner),
        backgroundColor: PlannerColors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Rencana baru',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _wide = constraints.maxWidth >= _wideBreakpoint;
          final list = _listPane(planner, plans);
          if (!_wide) return list;
          final selected = _selected;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: 380, child: list),
              const VerticalDivider(width: 1, color: PlannerColors.line),
              Expanded(
                child: selected == null
                    ? const Center(
                        child: Text(
                          'Pilih rencana untuk melihat hasilnya.',
                          style: TextStyle(
                            fontSize: 15,
                            color: PlannerColors.muted,
                          ),
                        ),
                      )
                    : PlanDetailPane(
                        key: ValueKey(selected),
                        planId: selected,
                        onChanged: planner.load,
                        onDeleted: () {
                          setState(() => _selected = null);
                          planner.load();
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _listPane(PlannerProvider planner, List<PlanSummary> plans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rencana Saya',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: PlannerColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${planner.plans.length} rencana',
                style: const TextStyle(
                  fontSize: 14,
                  color: PlannerColors.muted,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                onChanged: (query) =>
                    _debouncer.run(() => planner.search(query)),
                decoration: const InputDecoration(
                  hintText: 'Cari judul rencana',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              if (planner.offline) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PlannerColors.warnSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        color: PlannerColors.warn,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Offline: menampilkan daftar terakhir yang tersimpan di HP.',
                          style: TextStyle(
                            color: PlannerColors.warn,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: AsyncStateView(
            loading: planner.loading,
            hasData: planner.plans.isNotEmpty,
            error: planner.error,
            onRetry: planner.load,
            empty: plans.isEmpty,
            emptyMessage: planner.plans.isEmpty
                ? 'Belum ada rencana tersimpan.'
                : 'Tidak ada rencana dengan judul itu.',
            builder: (context) => RefreshIndicator(
              onRefresh: planner.load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: plans.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return Dismissible(
                    key: ValueKey(plan.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _delete(planner, plan),
                    background: const _DeleteBackground(),
                    child: PlanCard(
                      plan: plan,
                      selected: _wide && plan.id == _selected,
                      onTap: () => _open(planner, plan.id),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 22),
      decoration: BoxDecoration(
        color: PlannerColors.danger,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Hapus',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
