// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/core/router/app_router.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/teacher_assignment_repository.dart';
import '../../domain/assignment_creation_draft.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import 'module_ui_helper.dart';
import '../../../../core/l10n/app_language_controller.dart';

class ReviewAccessmentScreen extends StatefulWidget {
  const ReviewAccessmentScreen({super.key, this.draft});

  final AssignmentCreationDraft? draft;

  @override
  State<ReviewAccessmentScreen> createState() => _ReviewAccessmentScreenState();
}

class _ReviewAccessmentScreenState extends State<ReviewAccessmentScreen> {
  final _repo = TeacherAssignmentRepository();
  final _noteController = TextEditingController();
  bool _submitting = false;
  DateTime? _scheduleDueAt;

  @override
  void initState() {
    super.initState();
    _scheduleDueAt = _defaultDueDate();
    if (widget.draft == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Assignment details missing.'))),
        );
        Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  DateTime _defaultDueDate() {
    final now = DateTime.now();
    var daysUntilFriday = (DateTime.friday - now.weekday) % 7;
    if (daysUntilFriday == 0) daysUntilFriday = 7;
    final friday = DateTime(now.year, now.month, now.day).add(Duration(days: daysUntilFriday));
    return DateTime(friday.year, friday.month, friday.day, 23, 59);
  }

  String _scheduleTitle(DateTime? due) {
    if (due == null) return 'No due date';
    final now = DateTime.now();
    final diff = due.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff <= 7 && due.weekday == DateTime.friday) return 'Next Friday';
    return 'Due ${due.month}/${due.day}';
  }

  String _scheduleSubtitle(DateTime? due) {
    if (due == null) return 'Tap edit to set a due date';
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = due.hour % 12 == 0 ? 12 : due.hour % 12;
    final ampm = due.hour >= 12 ? 'PM' : 'AM';
    final minute = due.minute.toString().padLeft(2, '0');
    return '${weekdays[due.weekday - 1]} ${due.day}, ${months[due.month - 1]} ${due.year}, '
        '$hour:$minute $ampm';
  }

  String _recipientTitle(AssignmentCreationDraft draft) {
    if (draft.recipientMode == 'individual_students') {
      final count = draft.selectedStudentIds.length;
      return '$count selected students';
    }
    return draft.className ?? 'Selected class';
  }

  String _recipientSubtitle(AssignmentCreationDraft draft) {
    if (draft.recipientMode == 'individual_students') {
      return draft.className ?? 'Individual assignment';
    }
    final count = draft.recipientStudentCount ?? 0;
    return count > 0 ? '$count Students' : 'Entire class';
  }

  Future<void> _pickDueDate() async {
    final initial = _scheduleDueAt ?? _defaultDueDate();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null || !mounted) return;
    setState(() {
      _scheduleDueAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _submitAssignment() async {
    final draft = widget.draft;
    if (draft == null || _submitting) return;

    setState(() => _submitting = true);
    try {
      final payload = draft.copyWith(
        scheduleDueAt: _scheduleDueAt,
        teacherNote: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
      final created = await _repo.createAssignment(payload);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.assignmentdetail,
        (route) => route.settings.name == AppRouter.teacherassignmodule || route.isFirst,
        arguments: created.id,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final screenHeight = MediaQuery.of(context).size.height;

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      child: SizedBox(
        height: screenHeight - MediaQuery.of(context).padding.top,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(context.tr('Almost ready! Please confirm the details below\nbefore sending to your students.'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: draft == null
                    ? const SizedBox.shrink()
                    : ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _moduleCard(context, draft),
                          SizedBox(height: 14),
                          _infoCard(
                            context,
                            label: 'RECIPIENTS',
                            labelColor: const Color(0xFFFBBF24),
                            icon: Icons.groups_2,
                            title: _recipientTitle(draft),
                            subtitle: _recipientSubtitle(draft),
                            onEdit: () => Navigator.pop(context),
                          ),
                          SizedBox(height: 14),
                          _infoCard(
                            context,
                            label: 'SCHEDULE',
                            labelColor: const Color(0xFF2E7D32),
                            icon: Icons.calendar_today,
                            title: _scheduleTitle(_scheduleDueAt),
                            subtitle: _scheduleSubtitle(_scheduleDueAt),
                            onEdit: _pickDueDate,
                          ),
                          SizedBox(height: 20),
                          _teacherNote(context),
                          SizedBox(height: 20),
                        ],
                      ),
              ),
              _continueButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(context.tr('Review Assignment'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFF47495),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, size: 17, color: Color(0xFF1A1C1C)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moduleCard(BuildContext context, AssignmentCreationDraft draft) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            ModuleUiHelper.imageForCode(draft.moduleCode),
            width: 42,
            height: 42,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('SELECTED MODULE'),
                  style: TextStyle(
                    color: Color(0xFF2563C7),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  draft.moduleTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1C1C),
                      ),
                ),
                SizedBox(height: 6),
                Text(
                  draft.moduleDescription ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
          _editButton(onTap: () => Navigator.popUntil(
            context,
            (route) => route.settings.name == AppRouter.teacherassignmodule,
          )),
        ],
      ),
    );
  }

  Widget _infoCard(
    BuildContext context, {
    required String label,
    required Color labelColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onEdit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              _editButton(size: 28, onTap: onEdit),
            ],
          ),
          SizedBox(height: 12),
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFE5E7EB),
                  child: Icon(icon, size: 20, color: const Color(0xFF1A1C1C)),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1A1C1C),
                            ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF374151),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _teacherNote(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text(context.tr('✎  TEACHER NOTE  (optional)'),
              style: TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: .7,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _noteController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: '',
                hintText: context.tr('Add a little encouragement or specific\ninstructions for your students...'),
                hintStyle: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF1A1C1C),
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editButton({double size = 34, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFF3F4F6),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.edit, size: 16, color: Color(0xFF1F2937)),
      ),
    );
  }

  Widget _continueButton(BuildContext context) {
    return GestureDetector(
      onTap: _submitting ? null : _submitAssignment,
      child: Container(
        width: double.infinity,
        height: 58,
        margin: const EdgeInsets.symmetric(horizontal: 28),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _submitting ? const Color(0xFFB8E8E5) : const Color(0xFF62CEC8),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF62CEC8).withOpacity(.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _submitting
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(context.tr('SEND ASSIGNMENT'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: const Color(0xFF1A1C1C),
                    ),
              ),
      ),
    );
  }
}
