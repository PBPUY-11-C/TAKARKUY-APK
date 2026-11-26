import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takarkuy_apk/core/router/app_navigation.dart';
import 'package:takarkuy_apk/core/router/app_router.dart';
import 'package:takarkuy_apk/features/akun/data/auth_state.dart';
import 'package:takarkuy_apk/features/recipe_book/screens/recipe_list_page.dart';

import 'package:takarkuy_apk/features/pantry/pantry_page.dart';
import 'package:takarkuy_apk/features/planner/planner_page.dart';

const Color primaryGreen = Color(0xFF007452);
const Color darkGreen = Color(0xFF005B40);
const Color mutedColor = Color(0xFF64736E);
const Color borderColor = Color(0xFFE3ECE7);
const Color textColor = Color(0xFF172A22);
const Color pageColor = Color(0xFFF3F8F5);
const Color paleGreen = Color(0xFFEAF4EE);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardHome(
        onOpenRecipes: () => setState(() => _selectedIndex = 1),
        onOpenMarket: () => setState(() => _selectedIndex = 2),
      ),
      const MyRecipesPage(),
      const MarketLocatorPage(),
    ];

    return Scaffold(
      backgroundColor: pageColor,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: primaryGreen,
        unselectedItemColor: mutedColor,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Resep Saya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Market',
          ),
        ],
      ),
    );
  }
}

// ===============================
// DASHBOARD HOME
// ===============================

class DashboardHome extends StatelessWidget {
  final VoidCallback onOpenRecipes;
  final VoidCallback onOpenMarket;

  const DashboardHome({
    super.key,
    required this.onOpenRecipes,
    required this.onOpenMarket,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, viewport) {
          final bool isWide = viewport.maxWidth >= 760;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 28 : 16,
              vertical: isWide ? 22 : 16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BrandHeader(),
                    SizedBox(height: isWide ? 28 : 22),

                    _GreetingHeader(isWide: isWide, onOpenMarket: onOpenMarket),
                    SizedBox(height: isWide ? 22 : 18),

                    const SectionHeading(title: 'Ringkasan Dapur'),
                    const SizedBox(height: 10),

                    GridView.count(
                      crossAxisCount: isWide ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: isWide ? 2.05 : 1.65,
                      children: const [
                        SummaryCard(
                          title: 'Rencana aktif hari ini',
                          value: '0',
                          suffix: '',
                          icon: Icons.calendar_month_outlined,
                        ),
                        SummaryCard(
                          title: 'Segera digunakan',
                          value: '0',
                          suffix: ' bahan',
                          icon: Icons.access_time,
                        ),
                        SummaryCard(
                          title: 'Total masak',
                          value: '0',
                          suffix: ' kali',
                          icon: Icons.check_circle_outline,
                        ),
                        SummaryCard(
                          title: 'Resep Saya',
                          value: '0',
                          suffix: ' resep',
                          icon: Icons.menu_book_outlined,
                        ),
                      ],
                    ),

                    SizedBox(height: isWide ? 20 : 22),
                    const SectionHeading(title: 'Pintasan Modul'),
                    const SizedBox(height: 10),

                    GridView.count(
                      crossAxisCount: isWide ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: isWide ? 2.55 : 2.0,
                      children: [
                        ShortcutCard(
                          title: 'Meal Planner',
                          subtitle: 'Susun menu dan budget',
                          icon: Icons.calendar_month_outlined,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PlannerPage(),
                            ),
                          ),
                        ),
                        ShortcutCard(
                          title: 'Pantry',
                          subtitle: 'Cek stok dapur',
                          icon: Icons.kitchen_outlined,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PantryPage(),
                            ),
                          ),
                        ),
                        ShortcutCard(
                          title: 'Resep',
                          subtitle: 'Cari dan catat masak',
                          icon: Icons.menu_book_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RecipeListPage(),
                              ),
                            );
                          },
                        ),
                        ShortcutCard(
                          title: 'Tambah resep',
                          subtitle: 'Simpan resep andalanmu',
                          icon: Icons.add,
                          isNew: true,
                          onTap: onOpenRecipes,
                        ),
                      ],
                    ),

                    SizedBox(height: isWide ? 18 : 20),

                    if (isWide)
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: DashboardPanel(
                              title: 'Menu Hari Ini',
                              action: 'Rencana →',
                              child: EmptyState(
                                icon: Icons.restaurant_menu_outlined,
                                message: 'Belum ada rencana untuk hari ini.',
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            flex: 4,
                            child: DashboardPanel(
                              title: '7 Hari ke Depan',
                              action: 'Rencana →',
                              child: EmptyState(
                                icon: Icons.calendar_month_outlined,
                                message: 'Belum ada jadwal minggu ini.',
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      const Column(
                        children: [
                          DashboardPanel(
                            title: 'Menu Hari Ini',
                            action: 'Rencana →',
                            child: EmptyState(
                              icon: Icons.restaurant_menu_outlined,
                              message: 'Belum ada rencana untuk hari ini.',
                            ),
                          ),
                          SizedBox(height: 12),
                          DashboardPanel(
                            title: '7 Hari ke Depan',
                            action: 'Rencana →',
                            child: EmptyState(
                              icon: Icons.calendar_month_outlined,
                              message: 'Belum ada jadwal minggu ini.',
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 12),

                    DashboardPanel(
                      title: 'Resep Saya',
                      action: '+ Tambah resep',
                      onAction: onOpenRecipes,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const EmptyState(
                            icon: Icons.menu_book_outlined,
                            message: 'Belum ada resep tersimpan.',
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: onOpenRecipes,
                              icon: const Icon(Icons.add, size: 17),
                              label: const Text('Buat resep baru'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryGreen,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (isWide)
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DashboardPanel(
                              title: 'Segera Digunakan',
                              action: 'Pantry →',
                              child: EmptyState(
                                icon: Icons.inventory_2_outlined,
                                message: 'Tidak ada bahan yang mendekati tanggal kedaluwarsa.',
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: DashboardPanel(
                              title: 'Terakhir Dimasak',
                              action: 'Semua →',
                              child: EmptyState(
                                icon: Icons.history,
                                message:
                                    'Masakan yang dicatat akan tampil di sini.',
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      const Column(
                        children: [
                          DashboardPanel(
                            title: 'Segera Digunakan',
                            action: 'Pantry →',
                            child: EmptyState(
                              icon: Icons.inventory_2_outlined,
                              message: 'Tidak ada bahan yang mendekati tanggal kedaluwarsa.',
                            ),
                          ),
                          SizedBox(height: 12),
                          DashboardPanel(
                            title: 'Terakhir Dimasak',
                            action: 'Semua →',
                            child: EmptyState(
                              icon: Icons.history,
                              message:
                                  'Masakan yang dicatat akan tampil di sini.',
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 22),

                    const Center(
                      child: Text(
                        'TAKARKUY · Tata Kelola Anggaran dan Resep, Kuy!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: mutedColor, fontSize: 10),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===============================
// HEADER
// ===============================

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final authenticated = context.watch<AuthState?>()?.isAuthenticated ?? false;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: darkGreen,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.restaurant_menu,
            color: Colors.white,
            size: 19,
          ),
        ),
        const SizedBox(width: 9),
        const Text(
          'TAKARKUY',
          style: TextStyle(
            color: darkGreen,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: authenticated ? 'Akun Saya' : 'MasukKuy',
          onPressed: () => openRoute(
            context,
            authenticated ? AppRoutes.account : AppRoutes.login,
          ),
          icon: const Icon(Icons.person_outline, color: darkGreen),
        ),
      ],
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final bool isWide;
  final VoidCallback onOpenMarket;

  const _GreetingHeader({required this.isWide, required this.onOpenMarket});

  @override
  Widget build(BuildContext context) {
    const greeting = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DASHBOARD',
          style: TextStyle(
            color: mutedColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.3,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Hai, selamat datang 👋',
          style: TextStyle(
            color: textColor,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Yuk, atur makanan dan belanja hematmu.',
          style: TextStyle(color: mutedColor, fontSize: 12),
        ),
      ],
    );

    final marketButton = OutlinedButton.icon(
      onPressed: onOpenMarket,
      icon: const Icon(Icons.location_on_outlined, size: 17),
      label: const Text('Cari pasar terdekat'),
      style: OutlinedButton.styleFrom(
        foregroundColor: darkGreen,
        backgroundColor: Colors.white,
        side: const BorderSide(color: borderColor),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isWide && constraints.maxWidth >= 760) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: greeting),
              const SizedBox(width: 12),
              marketButton,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [greeting, const SizedBox(height: 12), marketButton],
        );
      },
    );
  }
}

// ===============================
// REUSABLE WIDGETS
// ===============================

class SectionHeading extends StatelessWidget {
  final String title;

  const SectionHeading({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: textColor,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String suffix;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.suffix,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08005B40),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: mutedColor, fontSize: 10),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: paleGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: darkGreen, size: 15),
              ),
            ],
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: suffix,
                  style: const TextStyle(
                    color: mutedColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShortcutCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isNew;
  final VoidCallback? onTap;

  const ShortcutCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: isNew ? paleGreen : Colors.white,
          border: Border.all(
            color: isNew ? const Color(0xFF9CB8A8) : borderColor,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: paleGreen,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, color: darkGreen, size: 17),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: mutedColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPanel extends StatelessWidget {
  final String title;
  final String? action;
  final Widget child;
  final VoidCallback? onAction;

  const DashboardPanel({
    super.key,
    required this.title,
    required this.child,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08005B40),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (action != null)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: darkGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    action!,
                    style: const TextStyle(
                      color: darkGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 6),
      child: Center(
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF99B4A8), size: 27),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: mutedColor, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// TEMPORARY MODULE PAGES
// ===============================

class MyRecipesPage extends StatelessWidget {
  const MyRecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        title: const Text('Resep Saya'),
        backgroundColor: Colors.white,
        foregroundColor: darkGreen,
        elevation: 0,
      ),
      body: const Center(child: Text('Halaman Resep Saya')),
    );
  }
}

class MarketLocatorPage extends StatelessWidget {
  const MarketLocatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        title: const Text('Pasar Terdekat'),
        backgroundColor: Colors.white,
        foregroundColor: darkGreen,
        elevation: 0,
      ),
      body: const Center(child: Text('Halaman Market Locator')),
    );
  }
}
