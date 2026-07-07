// ignore_for_file: deprecated_member_use, prefer_const_constructors, sized_box_for_whitespace, camel_case_types

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/core/router/app_router.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/teacher_messages_repository.dart';
import '../../data/teacher_struggling_models.dart';
import '../../data/teacher_struggling_repository.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../core/l10n/app_language_controller.dart';

class teachersStrugglingStudentsScreen extends StatefulWidget {
  const teachersStrugglingStudentsScreen({super.key});

  @override
  State<teachersStrugglingStudentsScreen> createState() =>
      _teachersStrugglingStudentsScreenState();
}

class _teachersStrugglingStudentsScreenState
    extends State<teachersStrugglingStudentsScreen> {
  final _repo = TeacherStrugglingRepository();
  final _messagesRepo = TeacherMessagesRepository();

  List<StrugglingStudentItem> _students = const [];
  bool _loading = true;
  final Set<int> _sendingIds = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _loading = true);
    try {
      final payload = await _repo.fetchStrugglingStudents();
      if (!mounted) return;
      setState(() {
        _students = payload.students;
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

  (IconData, Color) _trailingForAlert(String alertKey) {
    switch (alertKey) {
      case 'milestone_alert':
        return (Icons.timer_outlined, const Color(0xFFF59E0B));
      case 'phonemic_awareness':
        return (Icons.group_outlined, const Color(0xFF1D4ED8));
      default:
        return (Icons.extension_outlined, const Color(0xFFDC2626));
    }
  }

  Color _tagColorForAlert(String alertKey) {
    switch (alertKey) {
      case 'milestone_alert':
        return const Color(0xFF8A5A00);
      case 'phonemic_awareness':
        return const Color(0xFF1D4ED8);
      default:
        return const Color(0xFFDC2626);
    }
  }

  Future<void> _sendHelp(StrugglingStudentItem student) async {
    if (_sendingIds.contains(student.studentId)) return;
    setState(() => _sendingIds.add(student.studentId));
    try {
      final result = await _messagesRepo.sendIndividualMessage(
        studentId: student.studentId,
        messageType: 'progress_report',
        message: student.helpMessageSuggestion,
      );
      if (!mounted) return;
      final text = result.parentLinked
          ? '${context.tr('Help message sent for ')}${student.displayName}.'
          : '${context.tr('Help message saved for ')}${student.displayName}${context.tr(" — share Quest ID with parent.")}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: result.parentLinked ? const Color(0xFF2E7D32) : const Color(0xFF8A5A00),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } finally {
      if (mounted) {
        setState(() => _sendingIds.remove(student.studentId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitle = _students.isEmpty
        ? 'All students on track'
        : '${_students.length} student${_students.length == 1 ? '' : 's'} need attention';

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      child: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStudents,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: SizedBox(
                        height: 58,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(context.tr('Struggling Students'),
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1A1C1C),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _students.isEmpty
                                            ? const Color(0xFF9CA3AF)
                                            : const Color(0xFFFCC419),
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      subtitle,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF717786),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFF47495),
                                  ),
                                  child: const Icon(Icons.arrow_back, size: 18, color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_students.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.celebration_outlined, size: 48, color: Color(0xFF9CA3AF)),
                              SizedBox(height: 12),
                              Text(context.tr('Great news!'),
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4B5563),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(context.tr('No students need extra support right now.\nPull down to refresh after more activity.'),
                                textAlign: TextAlign.center,
                                style: textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    for (var i = 0; i < _students.length; i++) ...[
                      _studentCard(context, student: _students[i]),
                      if (i < _students.length - 1) SizedBox(height: 14),
                    ],
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _studentCard(BuildContext context, {required StrugglingStudentItem student}) {
    final textTheme = Theme.of(context).textTheme;
    final trailing = _trailingForAlert(student.alertKey);
    final tagColor = _tagColorForAlert(student.alertKey);
    final isSending = _sendingIds.contains(student.studentId);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F3F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFE5E7EB),
                child: Text(
                  student.initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1C1C),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      student.gradeLabel,
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF717786),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(trailing.$1, color: trailing.$2),
            ],
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 14, color: tagColor),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        student.tagLabel,
                        style: textTheme.labelSmall?.copyWith(
                          letterSpacing: .8,
                          fontWeight: FontWeight.w900,
                          color: tagColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  student.message,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: isSending ? null : () => _sendHelp(student),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF47495),
                foregroundColor: const Color(0xFF1A1C1C),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isSending
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.volunteer_activism_outlined, size: 18, color: Colors.black),
                        SizedBox(width: 8),
                        Text(context.tr('Send Help'),
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRouter.teachersdetail,
                  arguments: student.studentId,
                ),
                child: Text(context.tr('View Detail'),
                  style: textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
