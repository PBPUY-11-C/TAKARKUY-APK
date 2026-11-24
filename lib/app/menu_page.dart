import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:takarkuy_apk/core/router/app_router.dart';
import 'package:takarkuy_apk/core/theme/app_colors.dart';
import 'package:takarkuy_apk/core/widgets/left_drawer.dart';

/// Satu tombol modul di halaman awal beserta rute halaman yang dibukanya.
class ModuleItem {
  const ModuleItem(this.name, this.description, this.icon, this.route);

  final String name;
  final String description;
  final IconData icon;
  final String route;
}

/// Halaman awal aplikasi: header TAKARKUY dan kartu menuju kelima modul.
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  static const modules = [
    ModuleItem('Planner', 'Susun menu sesuai budget', Icons.calculate_outlined, AppRoutes.planner),
    ModuleItem('Pantry', 'Catat stok bahan di dapur', Icons.kitchen_outlined, AppRoutes.pantry),
    ModuleItem('Resep', 'Cari resep dan mulai masak', Icons.menu_book_outlined, AppRoutes.resep),
    ModuleItem('Dashboard', 'Ringkasan menu hari ini', Icons.space_dashboard_outlined,
        AppRoutes.dashboard),
    ModuleItem('Akun', 'Masuk atau daftar akun', Icons.person_outline, AppRoutes.login),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LeftDrawer(),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _Header()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) => SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  // Responsif: 2 kolom di HP, 3 kolom di tablet atau browser lebar.
                  crossAxisCount: constraints.crossAxisExtent >= 600 ? 3 : 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  // Tinggi tetap, bukan rasio, supaya teks tidak terpotong di layar sempit.
                  mainAxisExtent: 176,
                ),
                delegate: SliverChildListDelegate(
                  [for (final item in modules) ModuleCard(item)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Lingkaran lime sebagai aksen, ditumpuk di belakang teks dengan Stack.
          const Positioned(right: -40, top: -30, child: _Blob(size: 150, opacity: 0.9)),
          const Positioned(right: 70, bottom: -50, child: _Blob(size: 90, opacity: 0.35)),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'TAKARKUY',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Buka menu navigasi',
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Takar budget, pakai stok yang ada,\nmasak tanpa sisa.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.lime.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Kartu modul yang sedikit mengecil saat ditekan (AnimatedScale), lalu membuka halamannya.
class ModuleCard extends StatefulWidget {
  const ModuleCard(this.item, {super.key});

  final ModuleItem item;

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  bool _pressed = false;

  void _open() {
    context.push(widget.item.route);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return AnimatedScale(
      scale: _pressed ? 0.94 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _open,
          onHighlightChanged: (pressed) => setState(() => _pressed = pressed),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item.icon, color: AppColors.green, size: 28),
                ),
                const Spacer(),
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
