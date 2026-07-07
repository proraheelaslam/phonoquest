// ignore_for_file: deprecated_member_use, prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';

import '../../../../core/l10n/app_language_controller.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../data/celebration_report_models.dart';
import '../../data/teacher_dashboard_repository.dart';
import '../../data/teacher_reports_models.dart';
import '../../../../shared/widgets/app_scaffold.dart';

class CelebrationReportScreen extends StatefulWidget {
  const CelebrationReportScreen({super.key, this.classId});

  final int? classId;

  @override
  State<CelebrationReportScreen> createState() => _CelebrationReportScreenState();
}

class _CelebrationReportScreenState extends State<CelebrationReportScreen> {
  final _repo = TeacherDashboardRepository();
  CelebrationReportPayload? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final payload = await _repo.fetchCelebrationReport(classId: widget.classId);
      if (!mounted) return;
      setState(() {
        _data = payload;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  (Color, Color) _avatarColors(String name) {
    final colors = [
      (const Color(0xFFFFF1C2), const Color(0xFFB67A00)),
      (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)),
      (const Color(0xFFD1FAE5), const Color(0xFF10B981)),
      (const Color(0xFFFCE7F3), const Color(0xFFBE185D)),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final data = _data;

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      wrapInScrollView: false,
      child: _loading && data == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
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
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () => Navigator.maybePop(context),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                          ),
                          Text(
                            data?.title ?? 'Celebration Report',
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    _heroCard(context, data),
                    if (data != null) ...[
                      const SizedBox(height: 14),
                      _statsGrid(context, data.stats),
                      const SizedBox(height: 14),
                      _weeklyChart(context, data),
                      const SizedBox(height: 16),
                      Text(
                        context.tr('Top Performers'),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1C1C),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (data.topPerformers.isEmpty)
                        _emptyNote(context.tr('Top performers will appear once students start learning.'))
                      else
                        for (final student in data.topPerformers) ...[
                          _performerRow(context, student),
                          const SizedBox(height: 10),
                        ],
                      const SizedBox(height: 6),
                      Text(
                        context.tr('Celebration Highlights'),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1C1C),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (data.highlights.isEmpty)
                        _emptyNote(context.tr('Monthly wins from your class will show up here.'))
                      else
                        for (final highlight in data.highlights) ...[
                          _highlightRow(context, highlight),
                          const SizedBox(height: 10),
                        ],
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _heroCard(BuildContext context, CelebrationReportPayload? data) {
    final textTheme = Theme.of(context).textTheme;
    const ink = Color(0xFF1A1C1C);
    const actionColor = Color(0xFFB67A00);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(249, 244, 227, 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Image.asset(AppAssets.milestonereachedimage, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data?.monthLabel ?? '',
                  style: textTheme.labelMedium?.copyWith(
                    color: actionColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data?.className ?? context.tr('All Classes'),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data?.summary ??
                      context.tr('Loading your class celebration summary...'),
                  style: textTheme.bodySmall?.copyWith(
                    color: ink.withOpacity(.72),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsGrid(BuildContext context, CelebrationStats stats) {
    return Row(
      children: [
        Expanded(child: _statTile('Activities', '${stats.monthActivities}', const Color(0xFFF47495))),
        const SizedBox(width: 10),
        Expanded(child: _statTile('Skills', '${stats.completedSkills}', const Color(0xFFB67A00))),
        const SizedBox(width: 10),
        Expanded(child: _statTile('Mastery', '${stats.avgMasteryPct}%', const Color(0xFF0B57D0))),
      ],
    );
  }

  Widget _statTile(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F3F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF717786)),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _weeklyChart(BuildContext context, CelebrationReportPayload data) {
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(const Color(0xFFF47495), 'Completed'),
              const SizedBox(width: 16),
              _legendDot(const Color(0xFFFCC419), 'Assigned'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: bars.isEmpty
                ? Center(child: Text(context.tr('No activity yet')))
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: bars.map(_barColumn).toList(),
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
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF717786))),
      ],
    );
  }

  Widget _barColumn(WeeklyReportBar bar) {
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
                height: 80 * bar.completedRatio.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF47495),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 3),
              Container(
                width: 6,
                height: 80 * bar.assignedRatio.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCC419),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bar.dayLabel,
            style: const TextStyle(fontSize: 10, color: Color(0xFF717786), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _performerRow(BuildContext context, CelebrationPerformer student) {
    final textTheme = Theme.of(context).textTheme;
    final colors = _avatarColors(student.displayName);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.teachersdetail,
        arguments: student.studentId,
      ),
      child: Container(
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
              radius: 22,
              backgroundColor: colors.$1,
              child: Text(
                student.initials,
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: colors.$2),
              ),
            ),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 2),
                  Text(
                    student.badgeLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFB67A00),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (student.note != null && student.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      student.note!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF717786),
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${student.masteryPercent}%',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0B57D0),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF717786)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _highlightRow(BuildContext context, CelebrationHighlight highlight) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(249, 244, 227, 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F3F3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1C2),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.emoji_events_rounded, size: 20, color: Color(0xFFB67A00)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: textTheme.bodySmall?.copyWith(color: const Color(0xFF1A1C1C)),
                    children: [
                      TextSpan(
                        text: highlight.studentName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const TextSpan(text: ' • '),
                      TextSpan(
                        text: highlight.activityName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  highlight.timeLabel,
                  style: textTheme.labelSmall?.copyWith(color: const Color(0xFF717786)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1C2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              highlight.badgeText,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFFB67A00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyNote(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: const TextStyle(fontSize: 13, color: Color(0xFF717786), height: 1.25),
      ),
    );
  }
}
