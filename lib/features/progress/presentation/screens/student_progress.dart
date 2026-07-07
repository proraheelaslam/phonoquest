// ignore_for_file: deprecated_member_use, prefer_const_constructors, camel_case_types

import 'dart:math' as math show pi;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../data/student_progress_models.dart';
import '../../data/student_progress_repository.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/dashboard_bottom_nav_bar.dart';
import '../../../../core/l10n/app_language_controller.dart';

class studentProgressScreen extends StatefulWidget {
  const studentProgressScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<studentProgressScreen> createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends State<studentProgressScreen> {
  late Future<StudentProgressPayload> _progressFuture;
  final _repository = StudentProgressRepository();

  static const _weeklyBarColors = [
    Color(0xFFFF6C91),
    Color(0xFF0878F2),
    Color(0xFF168C3A),
  ];

  @override
  void initState() {
    super.initState();
    _progressFuture = _repository.fetchProgress();
  }

  Future<void> _reloadProgress() async {
    setState(() {
      _progressFuture = _repository.fetchProgress();
    });
    await _progressFuture;
  }

  Future<void> _showAllActivities() async {
    try {
      final activities = await _repository.fetchAllActivities();
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.72,
            minChildSize: 0.4,
            maxChildSize: 0.92,
            builder: (context, scrollController) {
              return ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: activities.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          context.tr('All Activity'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }

                  final item = activities[index - 1];
                  final icon = _activityIcon(item.activityType);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildActivityItem(
                      icon: icon.icon,
                      iconColor: icon.color,
                      title: item.title,
                      subtitle: item.category,
                      time: item.timeLabel,
                      showLine: index - 1 < activities.length - 1,
                    ),
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  ({IconData icon, Color color}) _activityIcon(String type) {
    switch (type) {
      case 'mastery':
        return (
          icon: Icons.check_circle_outline_rounded,
          color: const Color(0xFF168C3A),
        );
      case 'reading':
        return (
          icon: Icons.menu_book_rounded,
          color: const Color(0xFFFF6C91),
        );
      case 'word_build':
      default:
        return (
          icon: Icons.extension_rounded,
          color: const Color(0xFF987000),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      wrapInScrollView: false,
      bottomNavigationBar: widget.embeddedInShell
          ? null
          : DashboardBottomNavBar(
              currentIndex: DashboardBottomNavBar.indexFromRoute(
                ModalRoute.of(context)?.settings.name,
              ),
              onTap: (index) {
                final targetRoute = DashboardBottomNavBar.routeFromIndex(index);
                final currentRoute = ModalRoute.of(context)?.settings.name;
                if (targetRoute != currentRoute) {
                  Navigator.pushReplacementNamed(context, targetRoute);
                }
              },
            ),
      child: FutureBuilder<StudentProgressPayload>(
        future: _progressFuture,
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
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF475467),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: _reloadProgress,
                    child: Text(context.tr('Retry')),
                  ),
                ],
              ),
            );
          }

          final progress = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _reloadProgress,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppScaffold.pageScrollPadding(
                context,
                horizontal: 8,
                top: 8,
                clearBottomNav: true,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            _buildTopBar(context, progress.coins),
            SizedBox(height: 18),

          Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            progress.headline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF151515),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            progress.subtitle,
                            style: GoogleFonts.lexend(
                              fontSize: 11,
                              height: 1.25,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF151515),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 10),

                  Padding(
                    padding: const EdgeInsets.only(top: 0, right: 2),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Image.asset(
                        AppAssets.studentprogressimage,
                        fit: BoxFit.contain,

                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.22,
              children: [
                _StatCard(
                  bgColor: const Color(0xFFDCE5FF),
                  imagePath: AppAssets.activitiesimage,
                  value: progress.activitiesLabel,
                  valueColor: const Color(0xFF0878F2),
                  label: 'ACTIVITIES',
                ),
                _StatCard(
                  bgColor: const Color(0xFFFFE7B5),
                  imagePath: AppAssets.accuracyimage,
                  value: '${progress.accuracyPct}%',
                  valueColor: const Color(0xFFB78300),
                  label: 'ACCURACY',
                ),
                _StatCard(
                  bgColor: const Color(0xFFD7FAD8),
                  imagePath: AppAssets.practicedimage,
                  value: '${progress.wordsPracticed}',
                  valueColor: const Color(0xFF168C3A),
                  label: context.tr('WORDS PRACTICED'),
                ),
                _StatCard(
                  bgColor: const Color(0xFFFCE3F0),
                  imagePath: AppAssets.preminumimage,
                  value: progress.premiumLabel,
                  valueColor: const Color(0xFFFF3B93),
                  label: context.tr('PREMIUM'),
                  onTap: () => Navigator.pushNamed(context, AppRouter.subscription),
                ),
              ],
            ),

            SizedBox(height: 16),

                Container(
  width: double.infinity,
  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
  decoration: BoxDecoration(
    color: const Color(0xFFDDBBFF),
    borderRadius: BorderRadius.circular(14),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(context.tr('Phonics Accuracy'),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.black,
          height: 1.1,
        ),
      ),

      SizedBox(height: 2),

      Text(
        progress.phonicsAccuracyMessage,
        style: GoogleFonts.lexend(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.black.withOpacity(.7),
          height: 1,
        ),
      ),

      SizedBox(height: 12),

      Center(
  child: SizedBox(
    width: 170,
    height: 145,
    child: CustomPaint(
      painter: _SemiCircleProgressPainter(
        progress: progress.phonicsAccuracyPct / 100,
        backgroundColor: const Color(0xFFC9A7EA),
        progressColor: Colors.black,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [

          // Center Circle
          Positioned(
            bottom: 18,
            child: Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD6B5F3),
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${progress.phonicsAccuracyPct}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),

          // LEFT LABEL (Bottom)
          Positioned(
            left: 28,
            bottom: 0,
            child: Text(
              '0',
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),

          // RIGHT LABEL (Bottom)
          Positioned(
            right: 18,
            bottom: 0,
            child: Text(
              '100',
              style: GoogleFonts.lexend(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    ),
  ),
)
    ],
  ),
),

            SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('Words Built This Week'),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 18),
                  ...List.generate(progress.weeklyWordsBuilt.length, (index) {
                    final day = progress.weeklyWordsBuilt[index];
                    final color =
                        _weeklyBarColors[index % _weeklyBarColors.length];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < progress.weeklyWordsBuilt.length - 1
                            ? 12
                            : 0,
                      ),
                      child: _buildWeeklyBar(
                        day.dayLabel,
                        day.barRatio,
                        color,
                        '${day.count}',
                      ),
                    );
                  }),
                ],
              ),
            ),

            SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.tr('Recent Activity'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: _showAllActivities,
                  child: Text(context.tr('View All'),
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF6C91),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                children: [
                  ...List.generate(progress.recentActivities.length, (index) {
                    final item = progress.recentActivities[index];
                    final icon = _activityIcon(item.activityType);
                    return _buildActivityItem(
                      icon: icon.icon,
                      iconColor: icon.color,
                      title: item.title,
                      subtitle: item.category,
                      time: item.timeLabel,
                      showLine: index < progress.recentActivities.length - 1,
                    );
                  }),
                ],
              ),
            ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, int coins) {
  return Row(
    children: [

      /// LEFT SPACE
      SizedBox(width: 40),

      /// CENTER TITLE
      Expanded(
        child: Center(
          child: Text(context.tr('Progress Dashboard'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
      ),

      /// COINS
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE8B2),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.black.withOpacity(.08),
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              AppAssets.starimage,
              width: 13,
              height: 13,
              errorBuilder: (_, __, ___) {
                return const Icon(Icons.star, size: 13);
              },
            ),
            SizedBox(width: 4),
            Text(
              '$coins',
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),

      SizedBox(width: 8),

      /// NOTIFICATION
      IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: () =>
            Navigator.pushNamed(context, AppRouter.notifications),
        icon: const Icon(
          Icons.notifications_none_rounded,
          size: 24,
        ),
      ),
    ],
  );
}

  Widget _buildWeeklyBar(
    String day,
    double value,
    Color color,
    String count,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 38,
          child: Text(
            day,
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 16,
              backgroundColor: Colors.white.withOpacity(.55),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          width: 18,
          child: Text(
            count,
            textAlign: TextAlign.right,
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required bool showLine,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(icon, size: 14, color: Colors.white),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 58,
                color: const Color(0xFFD8D8D8),
              ),
          ],
        ),
        SizedBox(width: 22),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.lexend(
                    fontSize: 8,
                    color: const Color(0xFF5E6470),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final Color bgColor;
  final String imagePath;
  final String value;
  final Color valueColor;
  final String label;
  final VoidCallback? onTap;

  const _StatCard({
    required this.bgColor,
    required this.imagePath,
    required this.value,
    required this.valueColor,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              imagePath,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),

          // Reduced space here
          SizedBox(height: 0),

          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 9,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
              color: Colors.black.withOpacity(.35),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: card,
      ),
    );
  }
}

class _SemiCircleProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  const _SemiCircleProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 26.0;

    final rect = Rect.fromLTWH(
      23,
      22,
      size.width - 46,
      size.height + 28,
    );

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);
    canvas.drawArc(rect, math.pi, math.pi * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _SemiCircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}