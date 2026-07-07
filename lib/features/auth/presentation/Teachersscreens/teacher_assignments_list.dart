// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/core/router/app_router.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/teacher_assignment_models.dart';
import '../../data/teacher_assignment_repository.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import 'module_ui_helper.dart';
import '../../../../core/l10n/app_language_controller.dart';

class TeacherAssignmentsListScreen extends StatefulWidget {
  const TeacherAssignmentsListScreen({super.key});

  @override
  State<TeacherAssignmentsListScreen> createState() => _TeacherAssignmentsListScreenState();
}

class _TeacherAssignmentsListScreenState extends State<TeacherAssignmentsListScreen> {
  final _repo = TeacherAssignmentRepository();

  List<AssignmentDetail> _items = const [];
  bool _loading = true;
  String _filter = 'all';
  int? _cancellingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _repo.fetchAssignments(limit: 50);
      if (!mounted) return;
      setState(() {
        _items = items;
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

  List<AssignmentDetail> get _filtered {
    switch (_filter) {
      case 'active':
        return _items.where((a) => a.isActive).toList();
      case 'cancelled':
        return _items.where((a) => a.isCancelled).toList();
      default:
        return _items;
    }
  }

  void _openDetail(AssignmentDetail item) {
    Navigator.pushNamed(
      context,
      AppRouter.assignmentdetail,
      arguments: item.id,
    ).then((_) => _load());
  }

  Future<void> _confirmCancel(AssignmentDetail item) async {
    if (!item.isActive || _cancellingId != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('Cancel assignment?')),
        content: Text(
          'Students will no longer see "${item.moduleTitle}" as an active assignment.',
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

    setState(() => _cancellingId = item.id);
    try {
      await _repo.cancelAssignment(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Assignment cancelled.'))),
      );
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } finally {
      if (mounted) setState(() => _cancellingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visible = _filtered;

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      child: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context),
                    SizedBox(height: 12),
                    _filterChips(textTheme),
                    SizedBox(height: 14),
                    if (visible.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            _filter == 'all'
                                ? 'No assignments yet. Tap Assign Module to create one.'
                                : 'No $_filter assignments.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
                          ),
                        ),
                      )
                    else
                      ...visible.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _assignmentTile(context, item),
                          )),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _header(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(context.tr('Assignment History'),
            style: textTheme.titleLarge?.copyWith(
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

  Widget _filterChips(TextTheme textTheme) {
    Widget chip(String key, String label) {
      final selected = _filter == key;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => setState(() => _filter = key),
          selectedColor: const Color(0xFF62CEC8),
          labelStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? const Color(0xFF1A1C1C) : const Color(0xFF6B7280),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('all', 'All'),
          chip('active', 'Active'),
          chip('cancelled', 'Cancelled'),
        ],
      ),
    );
  }

  Widget _assignmentTile(BuildContext context, AssignmentDetail item) {
    final textTheme = Theme.of(context).textTheme;
    final statusColor = item.isActive ? const Color(0xFF10B981) : const Color(0xFF9CA3AF);
    final statusLabel = item.isActive ? 'ACTIVE' : item.status.toUpperCase();
    final isCancelling = _cancellingId == item.id;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openDetail(item),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.035),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    ModuleUiHelper.imageForCode(item.moduleCode),
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.moduleTitle,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1A1C1C),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          item.recipientSummary ?? '${item.studentCount} students',
                          style: textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusLabel,
                      style: textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    ModuleUiHelper.assignedDaysLabel(item.assignedDaysAgo ?? 0),
                    style: textTheme.labelSmall?.copyWith(color: const Color(0xFF6B7280)),
                  ),
                  if (item.scheduleDueLabel != null) ...[
                    SizedBox(width: 12),
                    Icon(Icons.event_outlined, size: 14, color: Colors.grey.shade600),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.scheduleDueLabel!,
                        style: textTheme.labelSmall?.copyWith(color: const Color(0xFF6B7280)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (item.isActive) ...[
                    const Spacer(),
                    TextButton(
                      onPressed: isCancelling ? null : () => _confirmCancel(item),
                      child: isCancelling
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(context.tr('Cancel'),
                              style: TextStyle(
                                color: Color(0xFFB42318),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
