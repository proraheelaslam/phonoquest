// ignore_for_file: camel_case_types, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../dashboard/data/student_home_models.dart';
import '../../../dashboard/data/student_home_repository.dart';
import '../../../dashboard/data/student_module_routes.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/dashboard_bottom_nav_bar.dart';
import '../../../../core/l10n/app_language_controller.dart';

class studentNotificationScreen extends StatefulWidget {
  const studentNotificationScreen({super.key});

  @override
  State<studentNotificationScreen> createState() => _studentNotificationScreenState();
}

class _studentNotificationScreenState extends State<studentNotificationScreen> {
  final _repo = StudentHomeRepository();
  late Future<List<StudentNotificationItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchNotifications();
  }

  void _reload() {
    setState(() => _future = _repo.fetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.dashboardimage,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  SizedBox(height: 28),
                  Expanded(
                    child: FutureBuilder<List<StudentNotificationItem>>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  snapshot.error is ApiException
                                      ? (snapshot.error as ApiException).message
                                      : 'Could not load notifications.',
                                ),
                                TextButton(onPressed: _reload, child: Text(context.tr('Retry'))),
                              ],
                            ),
                          );
                        }
                        final items = snapshot.data ?? const [];
                        if (items.isEmpty) {
                          return Center(child: Text(context.tr('No notifications yet.')));
                        }
                        final assignments = items.where((n) => n.kind == 'assignment').toList();
                        final activity = items.where((n) => n.kind != 'assignment').toList();
                        return RefreshIndicator(
                          onRefresh: () async => _reload(),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (assignments.isNotEmpty) ...[
                                  _sectionTitle('New Today'),
                                  SizedBox(height: 14),
                                  for (final item in assignments) ...[
                                    _apiNotificationCard(context, item: item),
                                    SizedBox(height: 17),
                                  ],
                                ],
                                if (activity.isNotEmpty) ...[
                                  _sectionTitle('Recent Activity'),
                                  SizedBox(height: 14),
                                  for (final item in activity) ...[
                                    _apiNotificationCard(context, item: item),
                                    SizedBox(height: 17),
                                  ],
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DashboardBottomNavBar(
        currentIndex: DashboardBottomNavBar.indexFromRoute(ModalRoute.of(context)?.settings.name),
        onTap: (index) {
          final targetRoute = DashboardBottomNavBar.routeFromIndex(index);
          final currentRoute = ModalRoute.of(context)?.settings.name;
          if (targetRoute != currentRoute) {
            Navigator.pushReplacementNamed(context, targetRoute);
          }
        },
      ),
    );
  }

  Widget _apiNotificationCard(BuildContext context, {required StudentNotificationItem item}) {
    final image = item.kind == 'assignment' ? AppAssets.forestimage : AppAssets.awardimage;
    final buttonColor = item.kind == 'assignment' ? const Color(0xFFDCEEFF) : const Color(0xFFFF6B8A);
    final buttonTextColor = item.kind == 'assignment' ? const Color(0xFF2F80ED) : Colors.black;
    return GestureDetector(
      onTap: item.route != null
          ? () => Navigator.pushNamed(context, studentModuleRoute(item.route!))
          : null,
      child: _notificationCard(
        imagePath: image,
        title: item.title,
        time: item.timeLabel,
        description: item.body,
        buttonText: item.ctaLabel,
        buttonColor: item.ctaLabel != null ? buttonColor : null,
        buttonTextColor: buttonTextColor,
      ),
    );
  }

  Widget _header(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Image.asset(AppAssets.backimage, width: 22, height: 22),
              ),
            ),
          ),
          Center(
            child: Text(
              'Notifications',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1C1C),
              ),
            ),
          ),
          const Positioned(
            right: 6,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(Icons.notifications_none_rounded, size: 22, color: Color(0xFF0B8F87)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1A1C1C),
        ),
      ),
    );
  }

  Widget _notificationCard({
    required String imagePath,
    required String title,
    required String time,
    required String description,
    String? buttonText,
    Color? buttonColor,
    Color buttonTextColor = Colors.black,
    bool compact = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, compact ? 15 : 16, 16, compact ? 15 : 17),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA).withOpacity(.95),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Image.asset(
              imagePath,
              width: compact ? 34 : 38,
              height: compact ? 34 : 38,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  description,
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                    color: const Color(0xFF414754),
                  ),
                ),
                if (buttonText != null) ...[
                  SizedBox(height: 11),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      buttonText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: buttonTextColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            time,
            textAlign: TextAlign.right,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1.3,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
