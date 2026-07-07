// ignore_for_file: camel_case_types, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/l10n/app_language_controller.dart';
import '../../../shared/widgets/teacher_bottom_nav_bar.dart';
import '../../auth/data/teacher_dashboard_repository.dart';
import '../../dashboard/data/student_home_models.dart';

class TeacherNotificationScreen extends StatefulWidget {
  const TeacherNotificationScreen({super.key});

  @override
  State<TeacherNotificationScreen> createState() => _TeacherNotificationScreenState();
}

class _TeacherNotificationScreenState extends State<TeacherNotificationScreen> {
  final _repo = TeacherDashboardRepository();
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
                        return RefreshIndicator(
                          onRefresh: () async => _reload(),
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => SizedBox(height: 14),
                            itemBuilder: (context, index) => _notificationCard(context, items[index]),
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
      bottomNavigationBar: teacherDashboardBottomNavBar(
        currentIndex: teacherDashboardBottomNavBar.indexFromRoute(ModalRoute.of(context)?.settings.name),
        onTap: (index) {
          final targetRoute = teacherDashboardBottomNavBar.routeFromIndex(index);
          final currentRoute = ModalRoute.of(context)?.settings.name;
          if (targetRoute != currentRoute) {
            Navigator.pushReplacementNamed(context, targetRoute);
          }
        },
      ),
    );
  }

  Widget _notificationCard(BuildContext context, StudentNotificationItem item) {
    final image = _iconForKind(item.kind);
    return GestureDetector(
      onTap: item.route != null && item.route!.isNotEmpty
          ? () => Navigator.pushNamed(context, item.route!)
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FA).withOpacity(.95),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Image.asset(image, width: 38, height: 38, fit: BoxFit.contain),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    item.body,
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                      color: const Color(0xFF414754),
                    ),
                  ),
                  if (item.ctaLabel != null) ...[
                    SizedBox(height: 11),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCEEFF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.ctaLabel!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2F80ED),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              item.timeLabel,
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
      ),
    );
  }

  String _iconForKind(String kind) {
    switch (kind) {
      case 'assignment_completed':
        return AppAssets.awardimage;
      case 'student_struggling':
        return AppAssets.teacherreportsimage;
      case 'parent_linked':
      case 'students_added':
        return AppAssets.teacherclassesimage;
      default:
        return AppAssets.awardimage;
    }
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
        ],
      ),
    );
  }
}
