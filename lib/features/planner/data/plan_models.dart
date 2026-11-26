/// Model data Planner, dibaca dari JSON API `/api/planner/`.
library;

int _int(Object? value) => value is num ? value.round() : int.tryParse('$value') ?? 0;

String _date(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// Satu rencana di daftar Rencana Saya.
class PlanSummary {
  const PlanSummary({
    required this.id,
    required this.title,
    required this.status,
    required this.startsOn,
    required this.version,
    required this.budget,
    required this.total,
  });

  factory PlanSummary.fromJson(Map<String, dynamic> json) => PlanSummary(
        id: json['id'] as String,
        title: json['title'] as String,
        status: json['status'] as String,
        startsOn: DateTime.parse(json['starts_on'] as String),
        version: _int(json['version']),
        budget: _int(json['budget']),
        total: _int(json['total']),
      );

  final String id;
  final String title;

  /// `draft` atau `saved`, sama dengan web.
  final String status;
  final DateTime startsOn;

  /// Wajib dikirim ulang saat menyimpan atau menghapus, agar perubahan dari perangkat lain tidak tertimpa.
  final int version;
  final int budget;
  final int total;

  bool get isDraft => status == 'draft';

  /// Bagian budget yang terpakai, 0 sampai 1 (bisa lebih dari 1 bila melebihi budget).
  double get budgetUsed => budget == 0 ? 0 : total / budget;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'status': status,
        'starts_on': _date(startsOn),
        'version': version,
        'budget': '$budget',
        'total': total,
      };

  @override
  bool operator ==(Object other) =>
      other is PlanSummary &&
      other.id == id &&
      other.title == title &&
      other.status == status &&
      other.startsOn == startsOn &&
      other.version == version &&
      other.budget == budget &&
      other.total == total;

  @override
  int get hashCode => Object.hash(id, title, status, startsOn, version, budget, total);
}

/// Satu menu dalam jadwal harian.
class PlanMeal {
  const PlanMeal({
    required this.type,
    required this.label,
    required this.name,
    required this.recipeCode,
    required this.cost,
    required this.calories,
    required this.servings,
  });

  factory PlanMeal.fromJson(Map<String, dynamic> json) => PlanMeal(
        type: json['type'] as String,
        label: json['label'] as String? ?? json['type'] as String,
        name: json['name'] as String,
        recipeCode: json['recipe_code'] as String,
        cost: _int(json['cost']),
        calories: _int(json['calories']),
        servings: _int(json['servings']),
      );

  final String type;
  final String label;
  final String name;
  final String recipeCode;
  final int cost;

  /// Kalori per porsi.
  final int calories;
  final int servings;
}

/// Satu hari dalam jadwal menu.
class PlanDay {
  const PlanDay({required this.number, required this.meals});

  factory PlanDay.fromJson(Map<String, dynamic> json) => PlanDay(
        number: _int(json['number']),
        meals: [for (final meal in json['meals'] as List) PlanMeal.fromJson(meal as Map<String, dynamic>)],
      );

  final int number;
  final List<PlanMeal> meals;
}

/// Satu bahan di daftar belanja; `netCost` sudah dikurangi stok Pantry.
class ShoppingItem {
  const ShoppingItem({required this.name, required this.quantity, required this.netCost});

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        name: json['name'] as String,
        quantity: json['quantity'] as num? ?? 0,
        netCost: _int(json['net_cost'] ?? json['cost']),
      );

  final String name;

  /// Jumlah dalam gram.
  final num quantity;
  final int netCost;
}

/// Kelompok bahan belanja, mis. "Bumbu".
class ShoppingGroup {
  const ShoppingGroup({required this.name, required this.items});

  factory ShoppingGroup.fromJson(Map<String, dynamic> json) => ShoppingGroup(
        name: json['name'] as String,
        items: [for (final item in json['items'] as List) ShoppingItem.fromJson(item as Map<String, dynamic>)],
      );

  final String name;
  final List<ShoppingItem> items;

  int get total => items.fold(0, (sum, item) => sum + item.netCost);
}

/// Gizi per hari dan perbandingannya dengan acuan harian yang dipakai web.
class Nutrition {
  const Nutrition({required this.calories, required this.protein, required this.carbs, required this.fat});

  factory Nutrition.fromJson(Map<String, dynamic> json) => Nutrition(
        calories: _int(json['calories']),
        protein: _int(json['protein']),
        carbs: _int(json['carbs']),
        fat: _int(json['fat']),
      );

  /// Acuan harian yang sama dengan NUTRITION_RINGS di apps/planner/plan_views.py.
  static const targets = [2150, 60, 325, 67];

  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  List<int> get values => [calories, protein, carbs, fat];

  /// Isi tiap cincin gizi, dibatasi 0 sampai 1.
  List<double> get ratios =>
      [for (var i = 0; i < targets.length; i++) (values[i] / targets[i]).clamp(0, 1).toDouble()];
}

/// Rencana lengkap: ringkasan, input, jadwal, belanja, dan gizi.
class PlanDetail {
  const PlanDetail({
    required this.summary,
    required this.days,
    required this.servings,
    required this.mealTypes,
    required this.targets,
    required this.rice,
    required this.withinBudget,
    required this.schedule,
    required this.shoppingGroups,
    required this.nutrition,
  });

  factory PlanDetail.fromJson(Map<String, dynamic> json) {
    final inputs = json['inputs'] as Map<String, dynamic>;
    final result = json['result'] as Map<String, dynamic>;
    return PlanDetail(
      summary: PlanSummary.fromJson(json),
      days: _int(inputs['days']),
      servings: _int(inputs['servings']),
      mealTypes: List<String>.from(inputs['meal_types'] as List),
      targets: List<String>.from(inputs['targets'] as List),
      rice: inputs['rice'] as String? ?? 'no',
      withinBudget: result['within_budget'] == true,
      schedule: [for (final day in result['schedule'] as List? ?? []) PlanDay.fromJson(day as Map<String, dynamic>)],
      shoppingGroups: [
        for (final group in result['shopping_groups'] as List? ?? []) ShoppingGroup.fromJson(group as Map<String, dynamic>),
      ],
      nutrition: Nutrition.fromJson(result['nutrition'] as Map<String, dynamic>? ?? const {}),
    );
  }

  final PlanSummary summary;
  final int days;
  final int servings;
  final List<String> mealTypes;
  final List<String> targets;
  final String rice;
  final bool withinBudget;
  final List<PlanDay> schedule;
  final List<ShoppingGroup> shoppingGroups;
  final Nutrition nutrition;

  int get itemCount => shoppingGroups.fold(0, (sum, group) => sum + group.items.length);
}

/// Isian form "Rencana baru" yang dikirim ke `POST /api/planner/plans/`.
class PlanInput {
  const PlanInput({
    required this.budget,
    required this.days,
    required this.servings,
    required this.mealTypes,
    required this.targets,
    required this.rice,
    this.excludeIngredients = const [],
  });

  final int budget;
  final int days;
  final int servings;
  final List<String> mealTypes;
  final List<String> targets;
  final String rice;
  final List<String> excludeIngredients;

  /// Budget per orang per hari, dibulatkan ke bawah seperti kalkulator web.
  int get perPersonPerDay => days * servings == 0 ? 0 : budget ~/ (days * servings);

  Map<String, dynamic> toJson() => {
        'budget': '$budget',
        'days': days,
        'servings': servings,
        'meal_types': mealTypes,
        'targets': targets,
        'rice': rice,
        'exclude_ingredients': excludeIngredients.join(', '),
      };
}

/// Format tanggal `yyyy-mm-dd` yang diterima API.
String apiDate(DateTime date) => _date(date);
