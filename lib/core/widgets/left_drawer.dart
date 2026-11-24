import 'package:flutter/material.dart';
import 'package:takarkuy_apk/features/akun/screens/akun_page.dart';
import 'package:takarkuy_apk/features/dashboard/screens/dashboard_screen.dart';
import 'package:takarkuy_apk/features/pantry/pantry_page.dart';
import 'package:takarkuy_apk/features/planner/planner_page.dart';
import 'package:takarkuy_apk/features/recipe_book/screens/recipe_list_page.dart';

/// Drawer navigasi bersama: kembali ke halaman awal atau membuka salah satu dari lima modul.
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  static const Color darkGreen = Color(0xFF1B4332);

  /// Menutup drawer lalu membuka halaman modul di atas halaman sekarang.
  static void _open(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final modules = <(IconData, String, Widget)>[
      (Icons.calendar_month_outlined, 'Smart Meal Planner', const PlannerPage()),
      (Icons.kitchen_outlined, 'Smart Pantry', const PantryPage()),
      (Icons.person_outline, 'Akun & Preferensi', const AkunPage()),
      (Icons.menu_book_outlined, 'Buku Resep & Masak', const RecipeListPage()),
      (Icons.dashboard_outlined, 'Dashboard & Market', const DashboardScreen()),
    ];
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: darkGreen,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TAKARKUY Mobile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tata Kelola Anggaran & Resep, Kuy!',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Halaman Utama'),
            onTap: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          const Divider(),
          for (final (icon, title, page) in modules)
            ListTile(
              leading: Icon(icon, color: darkGreen),
              title: Text(title),
              onTap: () => _open(context, page),
            ),
        ],
      ),
    );
  }
}
