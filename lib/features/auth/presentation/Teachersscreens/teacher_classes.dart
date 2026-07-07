// ignore_for_file: deprecated_member_use, prefer_const_constructors, sized_box_for_whitespace, camel_case_types

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import 'package:phonoquest_signup_flow/shared/widgets/teacher_bottom_nav_bar.dart';
import '../../../../core/router/app_router.dart';
import '../../data/classroom_models.dart';
import '../../data/teacher_workspace_controller.dart';
import '../../domain/class_creation_draft.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../core/l10n/app_language_controller.dart';

class teacherClassesScreen extends StatefulWidget {
  const teacherClassesScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<teacherClassesScreen> createState() => _teacherClassesScreenState();
}

class _teacherClassesScreenState extends State<teacherClassesScreen> {
  final _workspace = TeacherWorkspaceController.instance;

  @override
  void initState() {
    super.initState();
    _workspace.loadClasses();
  }

  Future<void> _loadClasses({bool force = false}) async {
    await _workspace.loadClasses(force: force);
  }

  Future<void> _openCreateClass() async {
    await Navigator.pushNamed(context, AppRouter.createnewclass);
    if (!mounted) return;
    await _workspace.loadClasses(force: true);
    _workspace.invalidateAll();
    await _workspace.loadDashboard(force: true);
  }

  void _manageClass(TeacherClassItem item) {
    Navigator.pushNamed(
      context,
      AppRouter.addstudentsclass,
      arguments: ClassCreationDraft(
        name: item.name,
        gradeLevel: item.gradeLevel ?? 'kindergarten',
        mascotCode: item.mascotCode ?? ClassCreationDraft.mascotCodes.first,
        classId: item.id,
      ),
    ).then((_) {
      if (!mounted) return;
      _workspace.loadClasses(force: true);
    });
  }

  IconData _mascotIcon(String? code) {
    switch (code) {
      case 'alphabet_lounge':
        return Icons.abc_rounded;
      case 'vowel_learning':
        return Icons.menu_book_outlined;
      case 'smart_chart':
        return Icons.grid_view_rounded;
      case 'phonics_cards':
        return Icons.style_outlined;
      case 'practice':
        return Icons.fitness_center_outlined;
      case 'blend_forest':
      default:
        return Icons.flutter_dash_rounded;
    }
  }

  Color _mascotBg(String? code) {
    switch (code) {
      case 'alphabet_lounge':
        return const Color(0xFFEAF7F6);
      case 'vowel_learning':
        return const Color(0xFFFFF3D6);
      case 'smart_chart':
        return const Color(0xFFEAF1FF);
      case 'phonics_cards':
        return const Color(0xFFFCE7F3);
      case 'practice':
        return const Color(0xFFE5F9F0);
      case 'blend_forest':
      default:
        return const Color(0xFFEAF7F6);
    }
  }

  Color _mascotColor(String? code) {
    switch (code) {
      case 'alphabet_lounge':
        return const Color(0xFF43C2BD);
      case 'vowel_learning':
        return const Color(0xFFF7B500);
      case 'smart_chart':
        return const Color(0xFF0B57D0);
      case 'phonics_cards':
        return const Color(0xFFBE185D);
      case 'practice':
        return const Color(0xFF10B981);
      case 'blend_forest':
      default:
        return const Color(0xFF43C2BD);
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
          final classes = _workspace.classes;
          final loading = _workspace.classesLoading && classes.isEmpty;
          final error = _workspace.classesError;

          return RefreshIndicator(
            onRefresh: () => _loadClasses(force: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppScaffold.pageScrollPadding(context),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        Text(
                          'Classes',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1A1C1C),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pushNamed(context, AppRouter.notifications),
                          icon: Image.asset(
                            AppAssets.teachernotificationimage,
                            width: 22,
                            height: 22,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(context.tr('Manage your cohorts and track learning progress.'),
                      style: textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF717786),
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 14),
                    _createNewClassCard(context, onTap: _openCreateClass),
                    SizedBox(height: 16),
                    if (loading)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (error != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Text(
                              error,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(color: Colors.red.shade800),
                            ),
                            SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => _loadClasses(force: true),
                              child: Text(context.tr('Retry')),
                            ),
                          ],
                        ),
                      )
                    else if (classes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(context.tr('No classes yet. Create your first class below.'),
                          style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF717786)),
                        ),
                      )
                    else
                      ...classes.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _classCard(
                            context,
                            item: item,
                            onManage: () => _manageClass(item),
                          ),
                        );
                      }),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
        },
      ),
    );
  }

  Widget _classCard(
    BuildContext context, {
    required TeacherClassItem item,
    required VoidCallback onManage,
  }) {
    final textTheme = Theme.of(context).textTheme;
    const ink = Color(0xFF1A1C1C);
    final infoText = item.summaryText ?? 'Track progress and manage your class roster.';
    final iconBg = _mascotBg(item.mascotCode);
    final iconColor = _mascotColor(item.mascotCode);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F5F7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        TeacherClassItem.gradeLabelFromApi(item.gradeLevel),
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: ink.withOpacity(.70),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      item.name,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: ink,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.group_outlined, size: 16, color: ink.withOpacity(.55)),
                        SizedBox(width: 6),
                        Text(
                          '${item.studentCount} Students',
                          style: textTheme.bodySmall?.copyWith(
                            color: ink.withOpacity(.60),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBg,
                  boxShadow: [
                    BoxShadow(
                      color: iconBg.withOpacity(.85),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(_mascotIcon(item.mascotCode), color: iconColor),
              ),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(context.tr('Overall Progress'),
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: ink.withOpacity(.65),
                  ),
                ),
              ),
              Text(
                item.overallProgress > 0 ? '${item.overallProgress}%' : context.tr('Not started'),
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: item.overallProgress > 0
                      ? const Color(0xFF0B57D0)
                      : ink.withOpacity(.45),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: item.progressFraction,
              minHeight: 10,
              backgroundColor: ink.withOpacity(.08),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0B57D0)),
            ),
          ),
          SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: ink.withOpacity(.70)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    infoText,
                    style: textTheme.bodySmall?.copyWith(
                      color: ink.withOpacity(.70),
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onManage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43C2BD),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.tr('Manage Class'),
                    style: textTheme.labelLarge?.copyWith(
                      color: ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18, color: ink),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createNewClassCard(BuildContext context, {required VoidCallback onTap}) {
    final textTheme = Theme.of(context).textTheme;
    const ink = Color(0xFF1A1C1C);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRoundedRectPainter(
          color: ink.withOpacity(.18),
          strokeWidth: 1.4,
          radius: 18,
          dashLength: 8,
          dashGap: 6,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          child: Column(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF47495),
                ),
                child: const Icon(Icons.add, size: 30, color: Colors.black),
              ),
              SizedBox(height: 14),
              Text(context.tr('Create New Class'),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: ink,
                ),
              ),
              SizedBox(height: 6),
              Text(context.tr('Set up a new class and start\nbringing joy to reading.'),
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: ink.withOpacity(.55),
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  _DashedRoundedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashLength,
    required this.dashGap,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + dashLength;
        canvas.drawPath(metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.dashGap != dashGap;
  }
}
