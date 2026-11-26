import 'package:flutter_test/flutter_test.dart';

import 'package:takarkuy_apk/features/planner/data/plan_models.dart';

import '../planner_fixtures.dart';

void main() {
  test('PlanSummary membaca daftar rencana dari API', () {
    final plan = PlanSummary.fromJson(summaryJson);

    expect(plan.id, 'f485e609-87f8-4ac3-bc2d-c0f5d3c51c76');
    expect(plan.title, 'Rencana Makan Saya');
    expect(plan.isDraft, isTrue);
    expect(plan.startsOn, DateTime(2026, 11, 26));
    expect(plan.version, 1);
    expect(plan.budget, 150000);
    expect(plan.total, 120000);
    expect(plan.budgetUsed, closeTo(0.8, 0.0001));
  });

  test('PlanSummary bisa disimpan ke cache dan dibaca lagi tanpa berubah', () {
    final plan = PlanSummary.fromJson(summaryJson);

    expect(PlanSummary.fromJson(plan.toJson()), plan);
  });

  test('PlanDetail membaca jadwal, belanja, dan gizi', () {
    final plan = PlanDetail.fromJson(detailJson);

    expect(plan.summary.title, 'Rencana Makan Saya');
    expect(plan.days, 3);
    expect(plan.servings, 2);
    expect(plan.withinBudget, isTrue);
    expect(plan.schedule.single.number, 1);
    final breakfast = plan.schedule.single.meals.first;
    expect(breakfast.label, 'Pagi');
    expect(breakfast.name, 'Nasi Goreng Telur Pakcoy');
    expect(breakfast.cost, 6300);
    expect(breakfast.calories, 345);
    expect(plan.shoppingGroups.single.name, 'Bumbu');
    expect(plan.shoppingGroups.single.items.length, 2);
    expect(plan.shoppingGroups.single.total, 3500);
    expect(plan.nutrition.calories, 1072);
    expect(plan.nutrition.fat, 22);
  });

  test('cincin gizi dihitung terhadap acuan harian yang sama dengan web', () {
    const nutrition = Nutrition(calories: 1109, protein: 59, carbs: 186, fat: 20);

    expect(nutrition.ratios, [
      closeTo(1109 / 2150, 0.0001),
      closeTo(59 / 60, 0.0001),
      closeTo(186 / 325, 0.0001),
      closeTo(20 / 67, 0.0001),
    ]);
    expect(const Nutrition(calories: 4000, protein: 0, carbs: 0, fat: 0).ratios.first, 1);
  });

  test('PlanInput dikirim dengan format yang diterima API', () {
    const input = PlanInput(
      budget: 150000,
      days: 3,
      servings: 2,
      mealTypes: ['sarapan', 'makan_malam'],
      targets: ['seimbang'],
      rice: 'nasi',
      excludeIngredients: ['udang', 'kacang'],
    );

    expect(input.toJson(), {
      'budget': '150000',
      'days': 3,
      'servings': 2,
      'meal_types': ['sarapan', 'makan_malam'],
      'targets': ['seimbang'],
      'rice': 'nasi',
      'exclude_ingredients': 'udang, kacang',
    });
    expect(input.perPersonPerDay, 25000);
  });
}
