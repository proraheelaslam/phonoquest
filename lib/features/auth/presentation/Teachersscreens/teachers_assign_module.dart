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

class AssignNewModuleScreen extends StatefulWidget {
  const AssignNewModuleScreen({super.key});

  @override
  State<AssignNewModuleScreen> createState() => _AssignNewModuleScreenState();
}

class _AssignNewModuleScreenState extends State<AssignNewModuleScreen> {
  final _repo = TeacherAssignmentRepository();

  TeacherModulesCatalog? _catalog;
  bool _loading = true;
  String? _highlightCode;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() => _loading = true);
    try {
      final catalog = await _repo.fetchModulesCatalog();
      if (!mounted) return;
      final level2 = catalog.modules.where((m) => m.levelNumber == 2).toList();
      final defaultCode = level2.isNotEmpty
          ? level2.first.code
          : (catalog.modules.isNotEmpty ? catalog.modules.first.code : null);
      setState(() {
        _catalog = catalog;
        _highlightCode = defaultCode;
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

  ModuleCatalogItem? _moduleByCode(String code) {
    for (final module in _catalog?.modules ?? const <ModuleCatalogItem>[]) {
      if (module.code == code) return module;
    }
    return null;
  }

  AssignmentCreationDraft _draftFor(ModuleCatalogItem module) {
    return AssignmentCreationDraft(
      moduleCode: module.code,
      moduleTitle: module.title,
      moduleDescription: module.description,
      levelLabel: module.levelLabel,
    );
  }

  void _openRecipients(ModuleCatalogItem module) {
    Navigator.pushNamed(
      context,
      AppRouter.selectrecipients,
      arguments: _draftFor(module),
    );
  }

  void _openAssignmentDetail(int assignmentId) {
    Navigator.pushNamed(
      context,
      AppRouter.assignmentdetail,
      arguments: assignmentId,
    ).then((_) => _loadCatalog());
  }

  void _openRecentForReassign(RecentlyAssignedItem item) {
    final module = _moduleByCode(item.moduleCode);
    Navigator.pushNamed(
      context,
      AppRouter.selectrecipients,
      arguments: AssignmentCreationDraft(
        moduleCode: item.moduleCode,
        moduleTitle: item.moduleTitle,
        moduleDescription: item.description ?? module?.description,
        levelLabel: module?.levelLabel ?? 'Level 1',
      ),
    );
  }

  void _openAllAssignments() {
    Navigator.pushNamed(context, AppRouter.teacherassignmentslist)
        .then((_) => _loadCatalog());
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
          : RefreshIndicator(
              onRefresh: _loadCatalog,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppScaffold.pageScrollPadding(context, top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(context),
                    SizedBox(height: 16),
                    if (_catalog?.recentlyAssigned.isNotEmpty == true)
                      _topBanner(context, _catalog!.recentlyAssigned.first),
                    if (_catalog?.recentlyAssigned.isNotEmpty == true) SizedBox(height: 14),
                    ...?_catalog?.modules.map(
                      (module) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _assignmentCard(
                          context,
                          module: module,
                          selected: module.code == _highlightCode,
                          onAssign: () => _openRecipients(module),
                        ),
                      ),
                    ),
                    if (_catalog?.modules.isEmpty ?? true)
                      Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text(context.tr('No modules available yet.'))),
                      ),
                    SizedBox(height: 8),
                    _recentHeader(context),
                    SizedBox(height: 12),
                    ...?_catalog?.recentlyAssigned.map(
                      (item) {
                        final module = _moduleByCode(item.moduleCode);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _recentCard(
                            context,
                            item: item,
                            level: module?.levelLabel ?? 'Level 1',
                            imagePath: ModuleUiHelper.imageForCode(item.moduleCode),
                            onView: () => _openAssignmentDetail(item.assignmentId),
                            onReassign: () => _openRecentForReassign(item),
                          ),
                        );
                      },
                    ),
                    if (_catalog?.recentlyAssigned.isEmpty ?? true)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(context.tr('No recent assignments yet.'),
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _header(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final readyModule = _highlightCode == null ? null : _moduleByCode(_highlightCode!);

    return SizedBox(
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.tr('Assign Module'),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1C1C),
                ),
              ),
              if (readyModule != null) ...[
                SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFCC419),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '${readyModule.levelLabel} ready',
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF717786),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
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

  Widget _topBanner(BuildContext context, RecentlyAssignedItem recent) {
    final textTheme = Theme.of(context).textTheme;
    final module = _moduleByCode(recent.moduleCode);

    return InkWell(
      onTap: () => _openAssignmentDetail(recent.assignmentId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xFF62CEC8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module?.levelLabel != null
                        ? '${module!.levelLabel} ready'
                        : recent.moduleTitle,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    recent.recipientSummary,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.black.withOpacity(.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: Color(0xFF1A1C1C)),
          ],
        ),
      ),
    );
  }

  Widget _assignmentCard(
    BuildContext context, {
    required ModuleCatalogItem module,
    required bool selected,
    required VoidCallback onAssign,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final imagePath = ModuleUiHelper.imageForCode(module.code);
    final isLevel2 = module.levelNumber == 2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? const Color(0xFFBFD7FF) : const Color(0xFFF1F1F1),
          width: selected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -4,
            top: -6,
            child: Opacity(
              opacity: 0.32,
              child: Image.asset(imagePath, width: 92, height: 92, fit: BoxFit.contain),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _levelBadge(context, module.levelLabel, isLevel2),
              SizedBox(height: 12),
              Text(
                module.title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: selected ? const Color(0xFF0B5ED7) : const Color(0xFF1A1C1C),
                ),
              ),
              SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(right: 78),
                child: Text(
                  module.description ?? module.subtitle ?? '',
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF3F4652),
                    fontWeight: FontWeight.w500,
                    height: 1.22,
                  ),
                ),
              ),
              SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _assignButton(context, onAssign)),
                  if (selected) ...[
                    SizedBox(width: 14),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1FAE5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF16A34A),
                        size: 24,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _levelBadge(BuildContext context, String label, bool active) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFCC419) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active) ...[
            const Icon(Icons.star_rounded, size: 15, color: Color(0xFF1A1C1C)),
            SizedBox(width: 4),
          ],
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1A1C1C),
            ),
          ),
        ],
      ),
    );
  }


  Widget _assignButton(BuildContext context, VoidCallback onAssign) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onAssign,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF62CEC8),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.assignment_outlined, size: 14),
            SizedBox(width: 7),
            Flexible(
              child: Text(
                context.tr('Assign Module'),
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1C1C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            context.tr('Recently Assigned'),
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1A1C1C),
            ),
          ),
        ),
        InkWell(
          onTap: _openAllAssignments,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('See All History'),
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF62CEC8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 14, color: Color(0xFF62CEC8)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _recentCard(
    BuildContext context, {
    required RecentlyAssignedItem item,
    required String level,
    required String imagePath,
    required VoidCallback onView,
    required VoidCallback onReassign,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          Row(
            children: [
              _smallLevelBadge(context, level),
              const Spacer(),
              const Icon(Icons.more_vert, size: 18, color: Color(0xFF1A1C1C)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(imagePath, width: 34, height: 34, fit: BoxFit.contain),
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
                    SizedBox(height: 4),
                    Text(
                      item.description ?? item.recipientSummary,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF3F4652),
                        height: 1.18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1, height: 1),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                ModuleUiHelper.assignedDaysLabel(item.assignedDaysAgo),
                style: textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF3F4652),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onView,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDFA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'View',
                    style: textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF0D9488),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              InkWell(
                onTap: onReassign,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(context.tr('Re-assign'),
                    style: textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF0B5ED7),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallLevelBadge(BuildContext context, String level) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        level,
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: const Color(0xFF6B7280),
        ),
      ),
    );
  }
}
