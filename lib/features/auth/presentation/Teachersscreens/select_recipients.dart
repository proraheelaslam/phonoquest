// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/core/router/app_router.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/teacher_assignment_models.dart';
import '../../data/teacher_assignment_repository.dart';
import '../../domain/assignment_creation_draft.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import 'module_ui_helper.dart';
import '../../../../core/l10n/app_language_controller.dart';

class SelectRecipientsScreen extends StatefulWidget {
  const SelectRecipientsScreen({super.key, this.draft});

  final AssignmentCreationDraft? draft;

  @override
  State<SelectRecipientsScreen> createState() => _SelectRecipientsScreenState();
}

class _SelectRecipientsScreenState extends State<SelectRecipientsScreen> {
  final _repo = TeacherAssignmentRepository();

  AssignmentRecipientsPayload? _recipients;
  bool _loading = true;
  bool _isIndividualSelected = false;
  int? _selectedClassId;
  final Set<int> _selectedStudentIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.draft == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Please select a module first.'))),
        );
        Navigator.pop(context);
      });
      return;
    }
    _loadRecipients();
  }

  Future<void> _loadRecipients() async {
    final draft = widget.draft!;
    setState(() => _loading = true);
    try {
      final payload = await _repo.fetchRecipients(moduleCode: draft.moduleCode);
      if (!mounted) return;
      setState(() {
        _recipients = payload;
        _selectedClassId = payload.classes.isNotEmpty ? payload.classes.first.id : null;
        _selectedStudentIds
          ..clear()
          ..addAll(payload.catchUpRequired.map((s) => s.rosterId));
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

  void _toggleStudent(int rosterId) {
    setState(() {
      if (_selectedStudentIds.contains(rosterId)) {
        _selectedStudentIds.remove(rosterId);
      } else {
        _selectedStudentIds.add(rosterId);
      }
    });
  }

  void _continue() {
    final draft = widget.draft;
    final recipients = _recipients;
    if (draft == null || recipients == null) return;

    if (!_isIndividualSelected) {
      if (_selectedClassId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Please select a class.'))),
        );
        return;
      }
      final selectedClass = recipients.classes.firstWhere(
        (c) => c.id == _selectedClassId,
        orElse: () => recipients.classes.first,
      );
      Navigator.pushNamed(
        context,
        AppRouter.reviewaccesment,
        arguments: draft.copyWith(
          recipientMode: 'entire_class',
          classId: selectedClass.id,
          className: selectedClass.name,
          selectedStudentIds: const [],
          recipientStudentCount: selectedClass.studentCount,
        ),
      );
      return;
    }

    if (_selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Select at least one student.'))),
      );
      return;
    }

    final firstStudent = [
      ...recipients.catchUpRequired,
      ...recipients.onTrack,
    ].firstWhere((s) => _selectedStudentIds.contains(s.rosterId));

    Navigator.pushNamed(
      context,
      AppRouter.reviewaccesment,
      arguments: draft.copyWith(
        recipientMode: 'individual_students',
        classId: firstStudent.classId,
        className: firstStudent.className,
        selectedStudentIds: _selectedStudentIds.toList(),
        recipientStudentCount: _selectedStudentIds.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final draft = widget.draft;

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
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  draft == null
                      ? 'Select recipients'
                      : "Assigning '${draft.levelLabel}: ${draft.moduleTitle}' practice module.",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              SizedBox(height: 22),
              _tabs(context),
              SizedBox(height: 34),
              Expanded(
                child: _loading
                    ? Center(child: CircularProgressIndicator())
                    : (_isIndividualSelected
                        ? _individualStudentsView(context)
                        : _entireClassView(context)),
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
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(context.tr('Select Recipients'),
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
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFF47495),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, size: 18, color: Color(0xFF1A1C1C)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _isIndividualSelected = false),
                child: Container(
                  height: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !_isIndividualSelected ? const Color(0xFFF47495) : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(context.tr('Entire Class'),
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _isIndividualSelected = true),
                child: Container(
                  height: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _isIndividualSelected ? const Color(0xFFF47495) : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(context.tr('Individual Students'),
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _entireClassView(BuildContext context) {
    final classes = _recipients?.classes ?? const <ClassRecipient>[];
    if (classes.isEmpty) {
      return Center(child: Text(context.tr('No classes found. Create a class first.')));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(context.tr('Your Classes'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1C1C),
                ),
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(context.tr('Select a class to assign this module to all students.'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4B5563),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        SizedBox(height: 18),
        Expanded(
          child: ListView.separated(
            itemCount: classes.length,
            separatorBuilder: (_, __) => SizedBox(height: 16),
            itemBuilder: (context, index) {
              final classroom = classes[index];
              return _classCard(
                context,
                title: classroom.name,
                subtitle: '${classroom.studentCount} Students',
                selected: _selectedClassId == classroom.id,
                icon: index == 0 ? Icons.school : Icons.groups_2_outlined,
                onTap: () => setState(() => _selectedClassId = classroom.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _individualStudentsView(BuildContext context) {
    final catchUp = _recipients?.catchUpRequired ?? const <IndividualRecipient>[];
    final onTrack = _recipients?.onTrack ?? const <IndividualRecipient>[];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _sectionTitle(
          context,
          icon: Icons.assignment_late,
          iconColor: const Color(0xFFFBBF24),
          title: context.tr('Catch-up Required'),
          subtitle: context.tr('Students who missed the last assignment.'),
        ),
        SizedBox(height: 18),
        if (catchUp.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(context.tr('No students need catch-up for this module.')),
          ),
        ...catchUp.map(
          (student) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _studentCard(
              context,
              name: student.displayName,
              badgeText: student.missingCount > 0
                  ? '⚠ Missing ${student.missingCount}'
                  : 'Catch-up',
              selected: _selectedStudentIds.contains(student.rosterId),
              initials: ModuleUiHelper.initialsFor(student.displayName),
              onTap: () => _toggleStudent(student.rosterId),
            ),
          ),
        ),
        SizedBox(height: 28),
        _sectionTitle(
          context,
          icon: Icons.groups_2_outlined,
          iconColor: const Color(0xFFF0F1F3),
          title: context.tr('On Track'),
          subtitle: context.tr('Students currently up to date.'),
        ),
        SizedBox(height: 18),
        ...onTrack.map(
          (student) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _studentCard(
              context,
              name: student.displayName,
              badgeText: 'On track',
              selected: _selectedStudentIds.contains(student.rosterId),
              initials: ModuleUiHelper.initialsFor(student.displayName),
              onTap: () => _toggleStudent(student.rosterId),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _sectionTitle(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: iconColor,
            child: Icon(
              icon,
              color: iconColor == const Color(0xFFFBBF24)
                  ? const Color(0xFF1A1C1C)
                  : const Color(0xFF4B5563),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1C1C),
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentCard(
    BuildContext context, {
    required String name,
    required String badgeText,
    required bool selected,
    required String initials,
    required VoidCallback onTap,
  }) {
    final isMissing = badgeText.contains('Missing') || badgeText == 'Catch-up';
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE0FAF8) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF62CEC8) : Colors.transparent,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.035),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFE5E7EB),
              child: Text(
                initials,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
            SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1A1C1C),
                        ),
                  ),
                  SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isMissing ? const Color(0xFFFFD7D7) : const Color(0xFFD8F5D8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isMissing ? const Color(0xFFC03535) : const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            selected
                ? Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF62CEC8),
                      shape: BoxShape.rectangle,
                    ),
                    child: const Icon(Icons.check, size: 16, color: Color(0xFF1A1C1C)),
                  )
                : Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF9CA3AF), width: 1.5),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _classCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool selected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE0FAF8) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF62CEC8) : const Color(0xFFF1F1F1),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.035),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF2563C7) : const Color(0xFFF0F1F3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: selected ? Colors.white : const Color(0xFF4B5563), size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                ],
              ),
            ),
            selected
                ? Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF62CEC8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 16, color: Color(0xFF1A1C1C)),
                  )
                : Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _continueButton(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _continue,
      child: Container(
        width: double.infinity,
        height: 58,
        margin: const EdgeInsets.symmetric(horizontal: 28),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _loading ? const Color(0xFFB8E8E5) : const Color(0xFF62CEC8),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF62CEC8).withOpacity(.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(context.tr('CONTINUE'),
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
