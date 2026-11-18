import 'package:flutter/material.dart';
import 'package:takarkuy_apk/recipe_book/models/recipe.dart';
import 'package:takarkuy_apk/widgets/left_drawer.dart';

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  // Palet Warna Hijau Dark (Forest Green)
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color mediumDarkGreen = Color(0xFF2D6A4F);
  static const Color lightGreenBg = Color(0xFFE8F5E9);

  String _selectedMeal = 'semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _mealCategories = [
    {'label': 'Semua Waktu', 'value': 'semua'},
    {'label': 'Sarapan', 'value': 'sarapan'},
    {'label': 'Makan Siang', 'value': 'makan_siang'},
    {'label': 'Makan Malam', 'value': 'makan_malam'},
  ];

  // Data dummy realistis sesuai database katalog TAKARKUY
  final List<Recipe> _dummyRecipes = [
    Recipe(
      recipeCode: 'RCP-TUMIS-KANGKUNG',
      name: 'Tumis Kangkung Tempe Gurih',
      mealType: 'makan_siang',
      baseServings: 2,
      rawIngredients:
          '• 1 ikat kangkung segar (siangi)\n• 1/2 papan tempe (potong dadu)\n• 3 siung bawang merah\n• 2 siung bawang putih\n• 1 sdm saus tiram\n• Garam & minyak secukupnya',
      instructions:
          '1. Goreng tempe dadu hingga setengah matang, tiriskan.\n2. Tumis irisan bawang merah dan bawang putih hingga harum.\n3. Masukkan kangkung dan tempe, aduk cepat dengan api besar.\n4. Tambahkan saus tiram dan sedikit garam, aduk sebentar lalu angkat selagi renyah.',
    ),
    Recipe(
      recipeCode: 'RCP-NASI-GORENG-TELUR',
      name: 'Nasi Goreng Sayur Telur Ceplok',
      mealType: 'sarapan',
      baseServings: 1,
      rawIngredients:
          '• 1 piring nasi dingin\n• 1 butir telur ayam\n• 1 batang daun bawang iris\n• 30 gram wortel serut\n• 1 sdm kecap manis\n• 1/2 sdt garam & lada bubuk',
      instructions:
          '1. Goreng telur ceplok hingga matang sesuai selera, sisihkan.\n2. Tumis daun bawang dan wortel serut hingga harum.\n3. Masukkan nasi dingin, kecap manis, garam, dan lada.\n4. Aduk dengan api sedang hingga bumbu merata.\n5. Sajikan nasi goreng hangat dengan telur ceplok di atasnya.',
    ),
    Recipe(
      recipeCode: 'RCP-SAYUR-BENING-BAYAM',
      name: 'Sayur Bening Bayam & Jagung Manis',
      mealType: 'makan_malam',
      baseServings: 3,
      rawIngredients:
          '• 1 ikat bayam hijau segar\n• 1 buah jagung manis (potong bulat)\n• 2 siung bawang merah iris\n• 1 ruas temu kunci (memarkan)\n• 700 ml air\n• Garam dan gula pasir secukupnya',
      instructions:
          '1. Didihkan air, lalu masukkan bawang merah dan temu kunci.\n2. Masukkan jagung manis, masak hingga jagung empuk dan manisnya keluar.\n3. Bumbui dengan garam dan sedikit gula.\n4. Masukkan daun bayam, masak sebentar saja (1-2 menit) agar tetap segar.\n5. Angkat dan sajikan hangat.',
    ),
    Recipe(
      recipeCode: 'RCP-OREK-TEMPE-KECAP',
      name: 'Orek Tahu Tempe Kecap Manis',
      mealType: 'makan_siang',
      baseServings: 2,
      rawIngredients:
          '• 1 kotak tahu putih (potong dadu)\n• 1/2 papan tempe (potong dadu)\n• 3 buah cabai merah keriting\n• 2 siung bawang putih\n• 3 sdm kecap manis\n• Sedikit air dan garam',
      instructions:
          '1. Goreng tahu dan tempe hingga berkulit kuning kecokelatan, tiriskan.\n2. Tumis bawang putih dan cabai hingga matang dan wangi.\n3. Masukkan tahu, tempe, kecap manis, dan sedikit air.\n4. Masak hingga bumbu meresap dan kuah mengental kecokelatan.',
    ),
    Recipe(
      recipeCode: 'RCP-OMELET-SAYUR-HEMAT',
      name: 'Omelet Telur Sayur Kosan',
      mealType: 'sarapan',
      baseServings: 1,
      rawIngredients:
          '• 2 butir telur ayam\n• 1/4 buah kol (iris halus)\n• 1 batang daun bawang iris\n• Garam, lada, dan sedikit minyak goreng',
      instructions:
          '1. Kocok lepas telur bersama irisan kol, daun bawang, garam, dan lada.\n2. Panaskan sedikit minyak di wajan anti lengket.\n3. Tuang adonan telur, masak dengan api kecil hingga bagian bawah matang.\n4. Balik perlahan dan masak hingga kedua sisi matang merata.',
    ),
  ];

  List<Recipe> get _filteredRecipes {
    return _dummyRecipes.where((recipe) {
      final matchesQuery =
          recipe.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (recipe.rawIngredients?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      if (!matchesQuery) return false;
      if (_selectedMeal == 'semua') return true;
      return recipe.mealType == _selectedMeal;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = _filteredRecipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buku Resep',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          // 1. Kotak Pencarian Resep
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama resep atau bahan...',
                prefixIcon: const Icon(Icons.search, color: darkGreen),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: darkGreen, width: 1.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),

          // 2. Filter Kategori Waktu Makan
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _mealCategories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _mealCategories[index];
                final isSelected = _selectedMeal == category['value'];
                return ChoiceChip(
                  label: Text(category['label']!),
                  selected: isSelected,
                  selectedColor: darkGreen,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedMeal = category['value']!;
                      });
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // 3. Daftar Kartu Resep
          Expanded(
            child: recipes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'Tidak ada resep yang sesuai',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: lightGreenBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.restaurant_menu,
                              color: darkGreen,
                            ),
                          ),
                          title: Text(
                            recipe.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(
                                      recipe.mealType.replaceAll('_', ' '),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: darkGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor: lightGreenBg,
                                    side: BorderSide.none,
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${recipe.baseServings ?? 1} porsi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: darkGreen),
                          onTap: () {
                            _showRecipeDetail(context, recipe);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showRecipeDetail(BuildContext context, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Waktu: ${recipe.mealType.replaceAll('_', ' ')} • Porsi: ${recipe.baseServings ?? 1} orang',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const Divider(height: 24),
                  if (recipe.rawIngredients != null &&
                      recipe.rawIngredients!.isNotEmpty) ...[
                    const Text(
                      'Bahan-bahan:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recipe.rawIngredients!,
                      style: const TextStyle(height: 1.4),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'Langkah Memasak:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recipe.instructions.isNotEmpty
                        ? recipe.instructions
                        : 'Langkah memasak belum tersedia.',
                    style: const TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: mediumDarkGreen,
                          content: Text('Memulai memasak ${recipe.name}!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.timer_outlined),
                    label: const Text('Mulai Mode Memasak (Timer)'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
