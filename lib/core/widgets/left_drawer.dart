import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:takarkuy_apk/core/router/app_router.dart';
import 'package:takarkuy_apk/core/theme/app_colors.dart';

/// Drawer navigasi bersama: kembali ke halaman awal atau membuka salah satu dari lima modul.
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  static const _modules = <(IconData, String, String)>[
    (Icons.calendar_month_outlined, 'Smart Meal Planner', AppRoutes.planner),
    (Icons.kitchen_outlined, 'Smart Pantry', AppRoutes.pantry),
    (Icons.person_outline, 'Akun & Preferensi', AppRoutes.account),
    (Icons.menu_book_outlined, 'Buku Resep & Masak', AppRoutes.resep),
    (Icons.dashboard_outlined, 'Dashboard & Market', AppRoutes.dashboard),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.green,
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
              Scaffold.of(context).closeDrawer();
              context.go(AppRoutes.home);
            },
          ),
          const Divider(),
          for (final (icon, title, route) in _modules)
            ListTile(
              leading: Icon(icon, color: AppColors.green),
              title: Text(title),
              onTap: () {
                Scaffold.of(context).closeDrawer();
                context.push(route);
              },
            ),
        ],
      ),
    );
  }
}
