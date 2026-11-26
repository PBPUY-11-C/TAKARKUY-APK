import 'package:flutter/material.dart';

import '../data/plan_models.dart';
import '../planner_colors.dart';
import '../planner_format.dart';

/// Kartu satu rencana di Rencana Saya: judul, tanggal, status, dan pemakaian budget.
class PlanCard extends StatelessWidget {
  const PlanCard({super.key, required this.plan, this.onTap, this.selected = false});

  final PlanSummary plan;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final over = plan.budgetUsed > 1;
    return Material(
      color: selected ? PlannerColors.greenSoft : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? PlannerColors.green : PlannerColors.line, width: selected ? 2 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.title,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: PlannerColors.ink)),
                        const SizedBox(height: 4),
                        Text(formatShortDate(plan.startsOn),
                            style: const TextStyle(fontSize: 13, color: PlannerColors.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusChip(draft: plan.isDraft),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(formatRupiah(plan.total),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: PlannerColors.ink)),
                  const SizedBox(width: 6),
                  Text('/ ${formatRupiah(plan.budget)}',
                      style: const TextStyle(fontSize: 13, color: PlannerColors.muted)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: plan.budgetUsed.clamp(0, 1).toDouble(),
                  minHeight: 8,
                  backgroundColor: PlannerColors.line,
                  color: over ? PlannerColors.danger : PlannerColors.green,
                  semanticsLabel: 'Budget terpakai',
                ),
              ),
            ],
          ),
        ),
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
      child: Text(
        draft ? 'Draft' : 'Tersimpan',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: draft ? PlannerColors.warn : PlannerColors.greenText,
        ),
      ),
    );
  }
}
