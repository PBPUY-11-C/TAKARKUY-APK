/// Contoh JSON dari API Planner asli (dipotong), dipakai bersama oleh tes Planner.
const summaryJson = {
  'id': 'f485e609-87f8-4ac3-bc2d-c0f5d3c51c76',
  'title': 'Rencana Makan Saya',
  'status': 'draft',
  'starts_on': '2026-11-26',
  'version': 1,
  'budget': '150000',
  'total': 120000,
  'updated_at': '2026-11-26T10:37:43.894587+07:00',
};

const detailJson = {
  ...summaryJson,
  'inputs': {
    'budget': '150000',
    'days': 3,
    'servings': 2,
    'meal_types': ['sarapan', 'makan_siang', 'makan_malam'],
    'targets': ['seimbang'],
    'exclude_ingredients': '',
    'allergens': [],
    'halal_only': true,
    'rice': 'nasi',
  },
  'result': {
    'within_budget': true,
    'total': 120000,
    'net_total': 120000,
    'nutrition': {'calories': 1072, 'protein': 61, 'carbs': 171, 'fat': 22},
    'schedule': [
      {
        'number': 1,
        'calories': 1293,
        'protein': 65,
        'meals': [
          {
            'type': 'sarapan',
            'label': 'Pagi',
            'recipe_code': 'RCP-MVP-054',
            'name': 'Nasi Goreng Telur Pakcoy',
            'cost': 6300,
            'calories': 345,
            'servings': 2,
            'instructions': 'Tumis bawang dan pakcoy.',
          },
          {
            'type': 'makan_siang',
            'label': 'Siang',
            'recipe_code': 'RCP-MVP-034',
            'name': 'Nasi + Tumis Ayam Jagung',
            'cost': 12500,
            'calories': 477,
            'servings': 2,
          },
        ],
      },
    ],
    'shopping_groups': [
      {
        'name': 'Bumbu',
        'items': [
          {'ingredient_code': 'ING-BAWANG-MERAH', 'name': 'Bawang Merah', 'quantity': 35, 'cost': 1200, 'net_cost': 1200},
          {'ingredient_code': 'ING-BAWANG-PUTIH', 'name': 'Bawang Putih', 'quantity': 58, 'cost': 2300, 'net_cost': 2300},
        ],
      },
    ],
  },
};
