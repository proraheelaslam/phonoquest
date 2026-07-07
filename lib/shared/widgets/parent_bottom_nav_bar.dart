// ignore_for_file: deprecated_member_use, camel_case_types

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';

import '../../core/l10n/app_language_controller.dart';
import '../../core/router/app_router.dart';

class parentDashboardBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const parentDashboardBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final items = [
      _NavItem(label: t.navHome, icon: AppAssets.homeimage),
      _NavItem(label: t.navStatus, icon: AppAssets.statusimage),
      _NavItem(label: t.navResources, icon: AppAssets.noteimage),
      _NavItem(label: t.navSettings, icon: AppAssets.settingimage),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    debugPrint('DashboardBottomNavBar tap index=$index');
                    onTap?.call(index);
                  },
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOut,
                      width: selected ? 66 : 80,
                      height: selected ? 66 : 56,
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF53C8C1) : Colors.transparent,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            item.icon,
                            width: 22,
                            height: 22,
                            color: selected ? const Color(0xFF1A1C1C) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected ? const Color(0xFF1A1C1C) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  static int indexFromRoute(String? route) {
    switch (route) {
      case AppRouter.parentDashboard:
        return 0;
      case AppRouter.parentsstatusscreen:
        return 1;
      case AppRouter.parentsreportsscreen:
        return 2;
      case AppRouter.parentssettingscreen:
        return 3;
      default:
        return 0;
    }
  }

  static String routeFromIndex(int index) {
    const routes = [
      AppRouter.parentsdashboardscreen,
      AppRouter.parentsstatusscreen,
      AppRouter.parentsreportsscreen,
      AppRouter.parentssettingscreen,
    ];
    return routes[index.clamp(0, routes.length - 1)];
  }
}

class _NavItem {
  final String label;
  final String icon;

  const _NavItem({
    required this.label,
    required this.icon,
  });
}
