// ignore_for_file: deprecated_member_use, camel_case_types

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';

import '../../core/l10n/app_language_controller.dart';
import '../../core/router/app_router.dart';

class teacherDashboardBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const teacherDashboardBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final items = [
      _NavItem(label: t.navHome, icon: AppAssets.homeimage),
      _NavItem(label: t.navClasses, icon: AppAssets.teacherclassesimage),
      _NavItem(label: t.navReports, icon: AppAssets.teacherreportsimage),
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
      case AppRouter.teachersdashboard:
        return 0;
      case AppRouter.teachersclasses:
        return 1;
      case AppRouter.teachersreports:
        return 2;
      case AppRouter.teacherssettings:
        return 3;
      default:
        return 0;
    }
  }

  static String routeFromIndex(int index) {
    const routes = [
      AppRouter.teachersdashboard,
      AppRouter.teachersclasses,
      AppRouter.teachersreports,
      AppRouter.teacherssettings,
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
