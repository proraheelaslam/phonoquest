// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/teacher_assignment_models.dart';
import '../../data/teacher_assignment_repository.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import 'module_ui_helper.dart';
import '../../../../core/l10n/app_language_controller.dart';

class AccessmentDetailScreen extends StatefulWidget {
  const AccessmentDetailScreen({super.key, this.assignmentId});

  final int? assignmentId;

  @override
  State<AccessmentDetailScreen> createState() => _AccessmentDetailScreenState();
}

class _AccessmentDetailScreenState extends State<AccessmentDetailScreen> {
  final _repo = TeacherAssignmentRepository();

  AssignmentDetail? _detail;
  AssignmentAnalytics? _analytics;
  bool _loading = true;
  bool _cancelling = false;
  int _visibleStudents = 20;

  @override
  void initState() {
    super.initState();
    if (widget.assignmentId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Assignment not found.'))),
        );
        Navigator.pop(context);
      });
      return;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final id = widget.assignmentId!;
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _repo.fetchAssignmentDetail(id),
        _repo.fetchAssignmentAnalytics(id),
      ]);
      if (!mounted) return;
      setState(() {
        _detail = results[0] as AssignmentDetail;
        _analytics = results[1] as AssignmentAnalytics;
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

  Future<void> _cancelAssignment() async {
    final detail = _detail;
    if (detail == null || !detail.isActive || _cancelling) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('Cancel assignment?')),
        content: Text(
          'Students will no longer see "${detail.moduleTitle}" as an active task.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.tr('Keep'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.tr('Cancel assignment'), style: TextStyle(color: Color(0xFFB42318))),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await _repo.cancelAssignment(detail.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Assignment cancelled.'))),
      );
      await _loadData();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      wrapInScrollView: false,
      child: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _header(context),
                SizedBox(height: 12),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppScaffold.pageScrollPadding(context, top: 0, horizontal: 4),
                      children: [
                        _moduleCard(context),
                        SizedBox(height: 12),
                        _metaCard(context),
                        SizedBox(height: 12),
                        _metricCard(
                          icon: Icons.check_circle_outline,
                          iconColor: const Color(0xFF2E7D32),
                          label: context.tr('METRIC'),
                          labelColor: const Color(0xFF65A765),
                          title: 'Completion',
                          value: '${_analytics?.completionPercent ?? 0}%',
                          detail: '(${_analytics?.completedCount ?? 0}/${_analytics?.totalCount ?? 0})',
                        ),
                        SizedBox(height: 12),
                        _accuracyCard(),
                        SizedBox(height: 12),
                        _insightCard(),
                        SizedBox(height: 12),
                        _scoreDistributionCard(context),
                        SizedBox(height: 12),
                        _studentRoster(context),
                        if (_detail?.isActive == true) ...[
                          SizedBox(height: 16),
                          _cancelCard(context),
                        ],
                        SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  BoxDecoration _cardDecoration({double radius = 8}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.035),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(context.tr('Assignment Detail'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1C1C),
                ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(100),
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFF47495),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, size: 14, color: Color(0xFF1A1C1C)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaCard(BuildContext context) {
    final detail = _detail;
    if (detail == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _metaRow(Icons.people_outline, 'Recipients', detail.recipientSummary ?? '${detail.studentCount} students'),
          if (detail.scheduleDueLabel != null) ...[
            SizedBox(height: 10),
            _metaRow(Icons.event_outlined, 'Due', detail.scheduleDueLabel!),
          ],
          if (detail.teacherNote != null && detail.teacherNote!.trim().isNotEmpty) ...[
            SizedBox(height: 10),
            _metaRow(Icons.notes_outlined, 'Note', detail.teacherNote!),
          ],
        ],
      ),
    );
  }

  Widget _metaRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1C1C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cancelCard(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _cancelling ? null : _cancelAssignment,
      icon: _cancelling
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.cancel_outlined, color: Color(0xFFB42318)),
      label: Text(
        _cancelling ? 'Cancelling…' : 'Cancel assignment',
        style: const TextStyle(
          color: Color(0xFFB42318),
          fontWeight: FontWeight.w700,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: Color(0xFFFECACA)),
        backgroundColor: const Color(0xFFFFF5F5),
      ),
    );
  }

  Widget _moduleCard(BuildContext context) {
    final detail = _detail;
    final analytics = _analytics;
    final statusColor = detail?.isCancelled == true
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF6FD0C8);
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _cardDecoration(radius: 7),
      child: Row(
        children: [
          Image.asset(
            ModuleUiHelper.imageForCode(detail?.moduleCode ?? ''),
            width: 34,
            height: 34,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _smallTag(
                  text: detail?.status.toUpperCase() ?? 'RESULT',
                  color: statusColor,
                  textColor: const Color(0xFF1A1C1C),
                ),
                SizedBox(height: 4),
                Text(
                  analytics?.moduleTitle ?? detail?.moduleTitle ?? 'Assignment',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1C1C),
                      ),
                ),
                SizedBox(height: 1),
                Text(
                  analytics?.completedOnLabel != null
                      ? 'ASSIGNED ${analytics!.completedOnLabel!.toUpperCase()}'
                      : 'ASSIGNMENT ACTIVE',
                  style: const TextStyle(
                    color: Color(0xFF2563C7),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color labelColor,
    required String title,
    required String value,
    required String detail,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 19),
              const Spacer(),
              _pill(text: label, bgColor: labelColor.withOpacity(.18), textColor: labelColor),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1C1C),
                  height: 1.1,
                ),
              ),
              SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _accuracyCard() {
    final accuracy = _analytics?.avgAccuracyPercent ?? 0;
    final progress = (accuracy / 100).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.track_changes, color: Color(0xFF2563C7), size: 19),
              const Spacer(),
              _pill(
                text: 'METRIC',
                bgColor: const Color(0xFFDDEBFF),
                textColor: const Color(0xFF2563C7),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(context.tr('Avg. Accuracy'),
            style: TextStyle(
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 2),
          Text(
            '$accuracy%',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1C1C),
              height: 1.1,
            ),
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563C7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightCard() {
    final struggle = _analytics?.commonStruggles.isNotEmpty == true
        ? _analytics!.commonStruggles.first
        : null;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Color(0xFF8B6A1D), size: 19),
              const Spacer(),
              _pill(
                text: 'INSIGHT',
                bgColor: const Color(0xFFFFE8A3),
                textColor: const Color(0xFF9A7619),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(context.tr('Common Struggle'),
            style: TextStyle(
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 6),
          Text(
            struggle?.label ?? 'No common struggles yet',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1C1C),
            ),
          ),
          SizedBox(height: 6),
          Text(
            struggle == null
                ? 'Students are still working on this assignment.'
                : '${struggle.studentCount} students need support here.',
            style: const TextStyle(fontSize: 9, color: Color(0xFF374151)),
          ),
        ],
      ),
    );
  }

  Widget _scoreDistributionCard(BuildContext context) {
    final buckets = _analytics?.scoreDistribution ?? const <ScoreDistributionBucket>[];
    final counts = buckets.map((b) => b.studentCount).toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Text(context.tr('Score Distribution'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1C1C),
                    ),
              ),
              const Spacer(),
              Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.download, size: 13),
                    SizedBox(width: 5),
                    Text(context.tr('Export Data'),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(context.tr('How your class performed overall'),
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: CustomPaint(
              painter: _BarChartPainter(counts: counts),
              child: Container(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final bucket in buckets)
                Text(
                  bucket.label,
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700),
                ),
              if (buckets.isEmpty)
                Text(context.tr('No scores yet'), style: TextStyle(fontSize: 8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _studentRoster(BuildContext context) {
    final students = _analytics?.students ?? const <AssignmentAnalyticsStudent>[];
    final visible = students.take(_visibleStudents).toList();

    return Container(
      decoration: _cardDecoration(radius: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 7),
            child: Row(
              children: [
                Text(context.tr('Student Roster'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1C1C),
                      ),
                ),
                const Spacer(),
                Text(
                  '${students.length} students',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(context.tr('STUDENT'), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                ),
                Expanded(
                  child: Text(context.tr('SCORE'), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                ),
                Text(context.tr('ACTION'), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.tr('No students on this assignment yet.')),
            ),
          for (final student in visible)
            _studentRow(
              student.displayName,
              '${student.scorePercent}%',
              ModuleUiHelper.scoreColor(student.scorePercent),
              initials: student.initials,
            ),
          if (students.length > _visibleStudents) ...[
            SizedBox(height: 7),
            InkWell(
              onTap: () => setState(() => _visibleStudents += 20),
              child: Text(context.tr('Load 20 More Students'),
                style: TextStyle(
                  color: Color(0xFFF47495),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _studentRow(
    String name,
    String score,
    Color scoreColor, {
    String? initials,
  }) {
    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFFE5E7EB),
                      child: Text(
                        initials ?? '?',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                    SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1C1C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  score,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: scoreColor,
                  ),
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right, size: 17, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pill({
    required String text,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: textColor,
          letterSpacing: .6,
        ),
      ),
    );
  }

  Widget _smallTag({
    required String text,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.counts});

  final List<int> counts;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (counts.isEmpty) return;

    final maxCount = counts.reduce((a, b) => a > b ? a : b).clamp(1, 999);
    final barWidth = size.width / counts.length * 0.55;
    final gap = size.width / counts.length;

    final barPaint = Paint()..color = const Color(0xFF38BDF8);

    for (int i = 0; i < counts.length; i++) {
      final height = (counts[i] / maxCount) * (size.height * 0.85);
      final left = gap * i + (gap - barWidth) / 2;
      final top = size.height - height;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth, height),
          const Radius.circular(3),
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.counts != counts;
  }
}
