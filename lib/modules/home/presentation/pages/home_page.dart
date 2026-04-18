import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/config/colors.dart';
import 'package:unseen_scout/modules/home/presentation/controllers/home_controller.dart';
import 'package:unseen_scout/modules/missions/presentation/pages/missions_tab.dart';
import 'package:unseen_scout/modules/missions/presentation/pages/radar_page.dart';

class HomePage extends GetView<HomeController> {
  static const String route = '/home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            RadarPage(),
            MissionsTab(),
            _PlaceholderPage(label: 'ALERTS'),
            _PlaceholderPage(label: 'PROFILE'),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(controller: controller),
    );
  }
}

// ── Bottom navigation bar ─────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final HomeController controller;

  const _BottomNav({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final idx = controller.currentIndex.value;

      return Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.map_outlined,
                  label: 'RADAR',
                  active: idx == 0,
                  onTap: () => controller.onTabTapped(0),
                ),
                _NavItem(
                  icon: Icons.assignment_outlined,
                  label: 'TASKS',
                  active: idx == 1,
                  onTap: () => controller.onTabTapped(1),
                ),
                _NavItem(
                  icon: Icons.notifications_outlined,
                  label: 'ALERTS',
                  active: idx == 2,
                  onTap: () => controller.onTabTapped(2),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  label: 'PROFILE',
                  active: idx == 3,
                  onTap: () => controller.onTabTapped(3),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.iconColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stub pages for tabs not yet implemented ───────────────────────────────────
class _PlaceholderPage extends StatelessWidget {
  final String label;

  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
