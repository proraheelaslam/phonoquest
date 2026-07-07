// ignore_for_file: deprecated_member_use, prefer_const_constructors, sized_box_for_whitespace, camel_case_types

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import 'package:phonoquest_signup_flow/shared/widgets/teacher_bottom_nav_bar.dart';
import '../../../../core/router/app_router.dart';
import '../../data/teacher_reports_models.dart';
import '../../data/teacher_workspace_controller.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../core/l10n/app_language_controller.dart';

class teacherReportsScreen extends StatefulWidget {
  const teacherReportsScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<teacherReportsScreen> createState() => _teacherReportsScreenState();
}

class _teacherReportsScreenState extends State<teacherReportsScreen> {
  final _workspace = TeacherWorkspaceController.instance;
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _workspace.loadReports();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _loadReports(query: _searchController.text, force: true);
    });
  }

  Future<void> _loadReports({String? query, bool force = false}) async {
    await _workspace.loadReports(query: query, force: force, studentLimit: 100);
    if (!mounted) return;
    if (_workspace.reportsError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_workspace.reportsError!),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  void _onActionCardTap(String key) {
    switch (key) {
      case 'review_assignments':
        Navigator.pushNamed(context, AppRouter.reviewaccessment);
        break;
      case 'struggling_students':
        Navigator.pushNamed(context, AppRouter.teachersStrugglingStudents);
        break;
      case 'assign_module':
        Navigator.pushNamed(context, AppRouter.teacherassignmodule);
        break;
    }
  }

  IconData _actionIcon(String key) {
    switch (key) {
      case 'review_assignments':
        return Icons.check_box_outlined;
      case 'struggling_students':
        return Icons.warning_amber_rounded;
      default:
        return Icons.assignment_outlined;
    }
  }

  (Color, Color) _actionColors(String key) {
    switch (key) {
      case 'review_assignments':
        return (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8));
      case 'struggling_students':
        return (const Color(0xFFFFF1C2), const Color(0xFFFCC419));
      default:
        return (const Color(0xFFD1FAE5), const Color(0xFF10B981));
    }
  }

  (Color, Color) _avatarColors(String name) {
    final colors = [
      (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)),
      (const Color(0xFFFFF1C2), const Color(0xFF8A5A00)),
      (const Color(0xFFD1FAE5), const Color(0xFF10B981)),
      (const Color(0xFFFCE7F3), const Color(0xFFBE185D)),
    ];
    return colors[name.hashCode.abs() % colors.length];
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
          : teacherDashboardBottomNavBar(
              currentIndex: teacherDashboardBottomNavBar.indexFromRoute(ModalRoute.of(context)?.settings.name),
              onTap: (index) {
                final targetRoute = teacherDashboardBottomNavBar.routeFromIndex(index);
                final currentRoute = ModalRoute.of(context)?.settings.name;
                if (targetRoute != currentRoute) {
                  Navigator.pushReplacementNamed(context, targetRoute);
                }
              },
            ),
      child: ListenableBuilder(
        listenable: _workspace,
        builder: (context, _) {
          final data = _workspace.reports;
          final loading = _workspace.reportsLoading && data == null;

          if (loading) {
            return Center(child: CircularProgressIndicator());
          }
          if (data == null) {
            return Center(
              child: TextButton(
                onPressed: () => _loadReports(force: true),
                child: Text(context.tr('Retry')),
              ),
            );
          }

          return RefreshIndicator(
                  onRefresh: () => _loadReports(
                    query: _searchController.text,
                    force: true,
                  ),
                  child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppScaffold.pageScrollPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 50,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            'Reports',
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () => Navigator.pushNamed(context, AppRouter.notifications),
                              icon: const Icon(Icons.notifications_none_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      data.subtitle.isNotEmpty
                          ? data.subtitle
                          : 'Track phonics mastery and student progress with detailed class insights.',
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF717786),
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 16),
                    _statsRow(context, data.stats),
                    SizedBox(height: 16),
                    _classAccuracyCard(context, data.stats),
                    SizedBox(height: 16),
                    _weeklyChart(context, data),
                    SizedBox(height: 16),
                    for (final card in data.actionCards) ...[
                      _actionCard(
                        context,
                        icon: _actionIcon(card.key),
                        iconBg: _actionColors(card.key).$1,
                        iconColor: _actionColors(card.key).$2,
                        title: card.title,
                        subtitle: card.subtitle,
                        onTap: () => _onActionCardTap(card.key),
                      ),
                      SizedBox(height: 10),
                    ],
                    SizedBox(height: 6),
                    Text(context.tr('Student Performance'),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1C1C),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, size: 18, color: Color(0xFF717786)),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: context.tr('Find student...'),
                                hintStyle: textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF9CA3AF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    if (data.students.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(context.tr('No students found. Add students to a class to see performance.'),
                          style: textTheme.bodySmall?.copyWith(color: const Color(0xFF717786)),
                        ),
                      )
                    else
                      for (final student in data.students) ...[
                        _studentRow(context, student: student),
                        SizedBox(height: 10),
                      ],
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
        },
      ),
    );
  }

  Widget _statsRow(BuildContext context, ReportStats stats) {
    final textTheme = Theme.of(context).textTheme;
    final avgDelta = formatDeltaLabel(stats.averageAccuracyDeltaPct);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF3F3F3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('Average Accuracy'),
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF717786),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '${stats.averageAccuracyPct}%',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
                if (avgDelta.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        (stats.averageAccuracyDeltaPct ?? 0) >= 0
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 12,
                        color: const Color(0xFF10B981),
                      ),
                      SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          avgDelta,
                          style: textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF3F3F3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('Active Students'),
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF717786),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '${stats.activeStudents}/${stats.totalStudents}',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: stats.activeRatio.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFCC419)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _classAccuracyCard(BuildContext context, ReportStats stats) {
    final textTheme = Theme.of(context).textTheme;
    final delta = formatDeltaLabel(stats.classAccuracyDeltaPct);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F3F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1C2),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.emoji_events_rounded, size: 20, color: Color(0xFFFCC419)),
              ),
              SizedBox(width: 10),
              Text(context.tr('Class Accuracy'),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1C1C),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(context.tr('Overall phonics recognition accuracy across all active modules.'),
            style: textTheme.bodySmall?.copyWith(color: const Color(0xFF717786), height: 1.2),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${stats.classAccuracyPct}%',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1D4ED8),
                ),
              ),
              if (delta.isNotEmpty) ...[
                SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_upward_rounded, size: 12, color: Color(0xFF10B981)),
                      SizedBox(width: 2),
                      Text(
                        delta,
                        style: textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _weeklyChart(BuildContext context, TeacherReportsPayload data) {
    final textTheme = Theme.of(context).textTheme;
    final bars = data.weeklyActivity;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F3F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.weeklyChartTitle,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1C1C),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(const Color(0xFFF47495), 'Completed'),
              SizedBox(width: 16),
              _legendDot(const Color(0xFFFCC419), 'Assigned'),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: bars.isEmpty
                  ? [Expanded(child: Center(child: Text(context.tr('No activity yet'))))]
                  : bars
                      .map(
                        (bar) => _barChartColumn(
                          label: bar.dayLabel,
                          completed: bar.completedRatio,
                          assigned: bar.assignedRatio,
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF717786))),
      ],
    );
  }

  Widget _barChartColumn({required String label, required double completed, required double assigned}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 6,
                height: 80 * completed.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF47495),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              SizedBox(width: 3),
              Container(
                width: 6,
                height: 80 * assigned.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCC419),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF717786), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF3F3F3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: iconColor),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF717786),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF717786)),
          ],
        ),
      ),
    );
  }

  Widget _studentRow(BuildContext context, {required StudentPerformanceRow student}) {
    final textTheme = Theme.of(context).textTheme;
    final colors = _avatarColors(student.displayName);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F3F3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colors.$1,
            child: Text(
              student.initials,
              style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: colors.$2),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.displayName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '${student.lastActiveLabel} • ${student.masteryPercent}% mastery',
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF717786),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 32,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRouter.teachersdetail,
                arguments: student.studentId,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1D4ED8),
                side: const BorderSide(color: Color(0xFFDBEAFE)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Detail',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1D4ED8),
                    ),
                  ),
                  SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF1D4ED8)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
