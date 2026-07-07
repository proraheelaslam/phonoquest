// ignore_for_file: deprecated_member_use, prefer_const_constructors, sized_box_for_whitespace, camel_case_types, dead_code, unused_element

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import 'package:phonoquest_signup_flow/shared/widgets/teacher_bottom_nav_bar.dart';
import '../../../../core/auth/current_user_storage.dart';
import '../../../../core/router/app_router.dart';
import '../../data/teacher_dashboard_models.dart';
import '../../data/teacher_workspace_controller.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/primary_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../core/l10n/app_language_controller.dart';

enum _ActivityAvatarType { image, group }

enum _ActivityBadgeType { xp, badge, active }

class teachersDashboardScreen extends StatefulWidget {
  const teachersDashboardScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<teachersDashboardScreen> createState() => _TeachersDashboardScreenState();
}

class _TeachersDashboardScreenState extends State<teachersDashboardScreen> {
  final _workspace = TeacherWorkspaceController.instance;
  late Future<String> _displayNameFuture;

  @override
  void initState() {
    super.initState();
    _workspace.loadDashboard();
    _displayNameFuture = _teacherName();
  }

  Future<void> _reloadDashboard() async {
    await _workspace.loadDashboard(force: true);
  }

  Future<String> _teacherName() async {
    final profile = await CurrentUserStorage.instance.readProfile();
    if (profile == null) return 'Teacher';
    final display = profile.displayName.trim();
    if (display.isNotEmpty) return display;
    final merged = [profile.firstName, profile.lastName]
        .where((s) => s.trim().isNotEmpty)
        .join(' ')
        .trim();
    return merged.isNotEmpty ? merged : 'Teacher';
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
      child: Builder(
        builder: (context) {
          const bool useNewDesign = true;
          if (useNewDesign) {
            return ListenableBuilder(
              listenable: _workspace,
              builder: (context, _) {
                if (_workspace.dashboardLoading && _workspace.dashboard == null) {
                  return Center(child: CircularProgressIndicator());
                }
                if (_workspace.dashboardError != null && _workspace.dashboard == null) {
                  final message = _workspace.dashboardError!;
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(message, textAlign: TextAlign.center),
                          SizedBox(height: 12),
                          TextButton(
                            onPressed: _reloadDashboard,
                            child: Text(context.tr('Retry')),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final data = _workspace.dashboard;
                if (data == null) {
                  return Center(child: CircularProgressIndicator());
                }
                return RefreshIndicator(
                  onRefresh: _reloadDashboard,
                  child: _buildDashboardV2(context, data),
                );
              },
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(
                      AppAssets.teacherprofileimage,
                    ),
                    child: Icon(Icons.person_rounded, size: 20),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('Hello'), style: textTheme.bodySmall),
                        FutureBuilder<String>(
                          future: _displayNameFuture,
                          builder: (context, snapshot) => Text(
                            snapshot.data ?? 'Teacher',
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, AppRouter.notifications),
                    icon: Image.asset(
                      'assets/images/notification.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ TEAL SECTION (ALL SIDES ROUNDED)
                  Container(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: const Color(0xFF43C2BD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('ACTIVE MODULE'),
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.black.withOpacity(.72),
                              fontWeight: FontWeight.w900,
                              letterSpacing: .6,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(context.tr('Alphabet Lounge'),
                            style: textTheme.headlineSmall?.copyWith(
                              color: Colors.black.withOpacity(.90),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(context.tr('Keep going, Leo! You’re almost at the master level for Letter Sounds.'),
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.black.withOpacity(.70),
                              height: 1.25,
                            ),
                          ),
                          SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Progress',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: Colors.black.withOpacity(.70),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Text(
                                '65%',
                                style: textTheme.labelMedium?.copyWith(
                                  color: Colors.black.withOpacity(.70),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: 0.65,
                              minHeight: 12,
                              backgroundColor: const Color(0xFF32B4AE),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFF7C653),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ✅ RESUME BUTTON (UNCHANGED)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Material(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                        onTap: () => Navigator.pushNamed(context, AppRouter.alphabet),
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(18),
                              bottomRight: Radius.circular(18),
                            ),
                            border: Border.all(
                              color: Colors.black.withOpacity(.06),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppAssets.playimage,
                                height: 24,
                                width: 24,
                              ),
                              SizedBox(width: 8),
                              Text(context.tr('RESUME LEARNING'),
                                style: textTheme.labelLarge?.copyWith(
                                  color: const Color(0xFFF47495),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: PrimaryCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: Colors.white,
                      child: SizedBox(
                        height: 46,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: ClipRRect(
                                child: Image.asset(
                                  AppAssets.goalimage,
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(context.tr('Daily Goal'),
                                    style: textTheme.labelMedium?.copyWith(fontSize: 7),
                                  ),
                                  Text(
                                    '15/20 mins',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: PrimaryCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: Colors.white,
                      child: SizedBox(
                        height: 46,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: ClipRRect(
                                child: Image.asset(
                                  AppAssets.wordimage,
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(context.tr('Words Mastered'),
                                    style: textTheme.labelMedium?.copyWith(fontSize: 7),
                                  ),
                                  Text(
                                    '124',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 7, right: 0),
                child: SectionHeader(
                  title: context.tr('Learning Adventures'),
                  subtitle: context.tr('Pick a quest and start your journey'),
                  titleStyle: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color.fromRGBO(26, 28, 28, 1),
                  ),
                  trailing: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TextButton(
                      onPressed: () {},
                      child: Text(context.tr('View All'),
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color.fromRGBO(83, 200, 193, 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PrimaryCard(
                      color: Colors.white,
                      onTap: () => Navigator.pushNamed(context, AppRouter.alphabet),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 72,
                            child: Center(
                              child: Image.asset(
                                AppAssets.exploreimage,
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(context.tr('Alphabet Lounge'),
                            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 4),
                          Text(context.tr('Master the A-Z phonics through music and play.'),
                            style: textTheme.bodySmall,
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Text(context.tr('Explore  ->'),
                              style: textTheme.labelLarge?.copyWith(
                                color: const Color.fromRGBO(36, 88, 181, 1),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: PrimaryCard(
                      color: Colors.white,
                      onTap: () => Navigator.pushNamed(context, AppRouter.blendforest),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 72,
                            child: Center(
                              child: Image.asset(
                                AppAssets.journeyimage,
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(context.tr('Blend Forrest'),
                            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 4),
                          Text(context.tr('Learn complex sounds like sh, ch and th.'),
                            style: textTheme.bodySmall,
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Text(context.tr('Journey  ->'),
                              style: textTheme.labelLarge?.copyWith(
                                color: const Color.fromRGBO(36, 88, 181, 1),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(224, 251, 252, 1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -34,
                      top: -22,
                      child: Container(
                        width: 120,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(.35),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 18,
                        right: 18,
                        bottom: 18,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 88,
                            height: 88,
                            child: Image.asset(
                              AppAssets.vowelimage,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 88,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(context.tr('Vowel Volcano'),
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1C1C),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(context.tr('Conquer the world of short and long vowels.'),
                                      style: textTheme.bodySmall,
                                    ),
                                    SizedBox(height: 14),
                                    Text(context.tr('Discover  →'),
                                      style: textTheme.labelLarge?.copyWith(
                                        color: const Color.fromRGBO(36, 88, 181, 1),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      color: const Color(0xFFE9E9EA),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 118,
                            height: 92,
                            child: Center(
                              child: Image.asset(
                                AppAssets.successimage,
                                width: 110,
                                height: 86,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(context.tr('Mastery Challenge'),
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(context.tr("Beat today's speed trial to earn\na 2x Gem Multiplier for 1 hour!"),
                                  style: textTheme.bodyMedium?.copyWith(height: 1.25),
                                ),
                                SizedBox(height: 14),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 6,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(.92),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFF7C653),
                                            ),
                                            child: Center(
                                              child: ClipOval(
                                                child: Image.asset(
                                                  AppAssets.minimage,
                                                  width: 20,
                                                  height: 20,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '5 MIN',
                                            style: textTheme.labelMedium?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(.92),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFF43C2BD),
                                            ),
                                            child: Center(
                                              child: ClipOval(
                                                child: Image.asset(
                                                  AppAssets.secimage,
                                                  width: 20,
                                                  height: 20,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '42 SEC',
                                            style: textTheme.labelMedium?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
                    child: Material(
                      color: const Color(0xFFF47495),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                        onTap: () {},
                        child: SizedBox(
                          height: 47,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.black.withOpacity(.85),
                              ),
                              SizedBox(width: 10),
                              Text(context.tr('START NOW'),
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .6,
                                  color: Colors.black.withOpacity(.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color.fromRGBO(255, 191, 0, 0.2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('Golden Ear Award'),
                            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 4),
                          Text(context.tr("You've identified 500 sounds\ncorrectly this week!"),
                            style: textTheme.bodyMedium?.copyWith(height: 1.25),
                          ),
                          SizedBox(height: 10),
                          Text(context.tr('Claim Reward'),
                            style: textTheme.labelLarge?.copyWith(
                              color: const Color(0xFF8C6A1A),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: Center(
                        child: Image.asset(
                          AppAssets.awardimage,
                          width: 86,
                          height: 86,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.emoji_events_rounded,
                              size: 60,
                              color: Colors.amber,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

Widget _milestoneReachedCard(
  BuildContext context,
  MilestoneInfo milestone, {
  VoidCallback? onReportTap,
}) {
  final textTheme = Theme.of(context).textTheme;

  const ink = Color(0xFF1A1C1C);
  const actionColor = Color(0xFFB67A00);

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [

      /// TOP CARD
      Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(249, 244, 227, 1.0),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.10),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ICON
              SizedBox(
                width: 45,
                height: 45,
                child: Image.asset(
                  AppAssets.milestonereachedimage,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(width: 10),

              /// TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      milestone.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: ink.withOpacity(.70),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      SizedBox(height: 0),

      /// SEPARATE BUTTON CARD
      Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12),bottomRight: Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(0),
          child: InkWell(
            borderRadius: BorderRadius.circular(0),
            onTap: onReportTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  milestone.reportLabel,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: actionColor,
                    letterSpacing: .2,
                  ),
                ),

                SizedBox(width: 6),

                const Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: actionColor,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

  Widget _moduleIconForCode(String moduleCode) {
    switch (moduleCode) {
      case 'alphabet_lounge':
        return Image.asset(AppAssets.exploreimage, width: 24, height: 24);
      case 'blend_forest':
        return Image.asset(AppAssets.journeyimage, width: 24, height: 24);
      default:
        return Image.asset(AppAssets.journeyimage, width: 24, height: 24);
    }
  }

  String _quickLinkAsset(String icon) {
    switch (icon) {
      case 'classroom':
        return AppAssets.managementimage;
      case 'report':
        return AppAssets.reportimage;
      case 'library':
        return AppAssets.libraryimage;
      case 'parents':
        return AppAssets.parentsimage;
      default:
        return AppAssets.managementimage;
    }
  }

  _ActivityBadgeType _badgeTypeFromApi(String value) {
    switch (value) {
      case 'badge':
        return _ActivityBadgeType.badge;
      case 'active':
        return _ActivityBadgeType.active;
      default:
        return _ActivityBadgeType.xp;
    }
  }

  VoidCallback? _quickLinkOnTap(BuildContext context, String icon) {
    switch (icon) {
      case 'classroom':
        return () => Navigator.pushNamed(context, AppRouter.teachersclasses);
      case 'report':
        return () => Navigator.pushNamed(context, AppRouter.teachersreports);
      case 'library':
        return () => Navigator.pushNamed(context, AppRouter.teacherlibrary);
      case 'parents':
        return () => Navigator.pushNamed(context, AppRouter.messageparents);
      default:
        return null;
    }
  }

  Future<void> _openCreateClass() async {
    await Navigator.pushNamed(context, AppRouter.createnewclass);
    if (!mounted) return;
    _reloadDashboard();
  }

  List<TeacherQuickLink> _ensureQuickLinks(List<TeacherQuickLink> links) {
    if (links.any((link) => link.icon == 'library')) return links;
    return [
      ...links,
      const TeacherQuickLink(
        title: 'Resource\nLibrary',
        url: '/teacher/library',
        icon: 'library',
        action: 'Explore  →',
      ),
    ];
  }

  Widget _buildDashboardV2(BuildContext context, TeacherDashboardPayload data) {
    final textTheme = Theme.of(context).textTheme;
    const ink = Color(0xFF1A1C1C);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppScaffold.pageScrollPadding(context, top: 14),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(AppAssets.teacherprofileimage),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('Hello,'), style: textTheme.bodySmall?.copyWith(color: ink.withOpacity(.65))),
                      FutureBuilder<String>(
                        future: _displayNameFuture,
                        builder: (context, snapshot) => Text(
                          snapshot.data ?? 'Teacher',
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: ink),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, AppRouter.notifications),
                  icon: Image.asset(
                    'assets/images/notification.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _createNewClassButton(context),
            SizedBox(height: 10),
            Text(
              data.subtitle,
              style: GoogleFonts.lexend(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color.fromRGBO(113, 119, 134, 1),
                height: 1.25,
              ),
            ),
            SizedBox(height: 12),
            _classMasteryCard(context, data.classMastery),
            SizedBox(height: 12),
            if (data.milestone != null)
              _milestoneReachedCard(
                context,
                data.milestone!,
                onReportTap: () => Navigator.pushNamed(
                  context,
                  AppRouter.teacherCelebrationReport,
                  arguments: data.classMastery.selectedClassId,
                ),
              ),
            SizedBox(height: 16),
            Text(context.tr('Active Modules'),
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: ink),
            ),
            if (data.activeModules.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ink.withOpacity(.06)),
                ),
                child: Text(
                  data.hasStudentActivity
                      ? 'No modules in progress right now.'
                      : 'Active modules appear when a student opens or completes a lesson.',
                  style: textTheme.bodyMedium?.copyWith(color: ink.withOpacity(.65)),
                ),
              )
            else if (data.activeModules.length == 1)
              _moduleCardV2(
                context,
                title: data.activeModules.first.title,
                subtitle: data.activeModules.first.description,
                moduleInfo: data.activeModules.first.moduleInfo,
                icon: _moduleIconForCode(data.activeModules.first.moduleCode),
                avatarCount: data.activeModules.first.studentCount,
              )
            else
              Row(
                children: [
                  for (int i = 0; i < data.activeModules.length && i < 2; i++) ...[
                    if (i > 0) SizedBox(width: 12),
                    Expanded(
                      child: _moduleCardV2(
                        context,
                        title: data.activeModules[i].title,
                        subtitle: data.activeModules[i].description,
                        moduleInfo: data.activeModules[i].moduleInfo,
                        icon: _moduleIconForCode(data.activeModules[i].moduleCode),
                        avatarCount: data.activeModules[i].studentCount,
                      ),
                    ),
                  ],
                ],
              ),
            SizedBox(height: 16),
            _studentSpotlightSection(context, data.studentSpotlight),
            SizedBox(height: 16),
            Text(context.tr('Quick Links'), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: ink)),
            SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.25,
              children: [
                for (final link in _ensureQuickLinks(data.quickLinks))
                  _quickLinkCard(
                    context,
                    title: link.title,
                    action: link.action,
                    image: _quickLinkAsset(link.icon),
                    onTap: _quickLinkOnTap(context, link.icon),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Text(context.tr('Recent Activity'), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: ink)),
            SizedBox(height: 10),
            if (data.recentActivities.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(context.tr('Student activity will show up here after they start learning.'),
                  style: textTheme.bodySmall?.copyWith(color: ink.withOpacity(.6)),
                ),
              )
            else
              for (final activity in data.recentActivities) ...[
                _activityTile(
                  context,
                  name: activity.studentName,
                  action: activity.actionVerb,
                  activityName: activity.activityName,
                  timeInfo: activity.timeInfo,
                  badgeType: _badgeTypeFromApi(activity.badgeType),
                  badgeText: activity.badgeText.isNotEmpty ? activity.badgeText : '—',
                  avatarType: _ActivityAvatarType.image,
                  avatarImage: AppAssets.studentAvatar,
                ),
                SizedBox(height: 10),
              ],
          ],
        ),
    );
  }

  Widget _createNewClassButton(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const ink = Color(0xFF1A1C1C);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _openCreateClass,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF47495),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(Icons.add, size: 22, color: Colors.black),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('Create New Class'),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: ink,
                    ),
                  ),
                  Text(
                    context.tr('Set up a new class and start bringing joy to reading.'),
                    style: textTheme.bodySmall?.copyWith(
                      color: ink.withOpacity(.72),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: ink),
          ],
        ),
      ),
    );
  }

  Widget _classMasteryCard(BuildContext context, ClassMasteryStats stats) {
    const ink = Color(0xFF1A1C1C);
    final hasActivity = stats.activeExplorers > 0;
    final progress = hasActivity ? stats.avgPhonicsProficiency / 100.0 : 0.0;

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
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: ink.withOpacity(.14)),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.workspace_premium_rounded, size: 14, color: ink.withOpacity(.85)),
              ),
              SizedBox(width: 8),
              Text(context.tr('Class Mastery'),
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _masteryMetric(
                  value: hasActivity ? '${stats.avgPhonicsProficiency}%' : '—',
                  captionLine1: 'Avg. Phonics',
                  captionLine2: 'Proficiency',
                  valueColor: const Color(0xFF0B57D0),
                  alignEnd: false,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 1,
                height: 54,
                color: ink.withOpacity(.08),
              ),
              Expanded(
                child: _masteryMetric(
                  value: '${stats.activeExplorers}',
                  captionLine1: 'Active',
                  captionLine2: 'Explorers',
                  valueColor: const Color(0xFFF7B500),
                  alignEnd: true,
                  center: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0B57D0)),
            ),
          ),
          if (!hasActivity && stats.rosterCount > 0) ...[
            SizedBox(height: 10),
            Text(
              context.tr('Waiting for students to start learning.'),
              style: GoogleFonts.lexend(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color.fromRGBO(113, 119, 134, 1),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _masteryMetric({
    required String value,
    required String captionLine1,
    required String captionLine2,
    required Color valueColor,
    required bool alignEnd,
    bool center = false,
  }) {
    final textAlign = center
        ? TextAlign.center
        : (alignEnd ? TextAlign.end : TextAlign.start);
    final crossAxisAlignment = center
        ? CrossAxisAlignment.center
        : (alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start);

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          value,
          textAlign: textAlign,
          style: GoogleFonts.lexend(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: valueColor,
            height: 1.0,
          ),
        ),
        SizedBox(height: 6),
        Text(
          captionLine1,
          textAlign: textAlign,
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color.fromRGBO(113, 119, 134, 1),
            height: 1.15,
          ),
        ),
        Text(
          captionLine2,
          textAlign: textAlign,
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color.fromRGBO(113, 119, 134, 1),
            height: 1.15,
          ),
        ),
      ],
    );
  }

  Widget _metricBlock(
    BuildContext context, {
    required String value,
    required String label,
    required Color valueColor,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: valueColor),
          ),
          SizedBox(height: 2),
          Text(label, style: textTheme.bodySmall?.copyWith(height: 1.1, color: const Color(0xFF1A1C1C))),
        ],
      ),
    );
  }

  Widget _moduleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String progressLabel,
    required double progress,
    required String chipText,
    required Color chipColor,
    required Color iconBg,
    required Widget icon,
  }) {
    final textTheme = Theme.of(context).textTheme;
    const ink = Color(0xFF1A1C1C);

    return Container(
      width: 240,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ink.withOpacity(.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
                alignment: Alignment.center,
                child: icon,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: ink),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  chipText,
                  style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: ink.withOpacity(.75)),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(color: ink.withOpacity(.65), height: 1.2),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(progressLabel, style: textTheme.labelSmall?.copyWith(color: ink.withOpacity(.55), fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${(progress * 100).round()}%', style: textTheme.labelSmall?.copyWith(color: ink.withOpacity(.55), fontWeight: FontWeight.w900)),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: ink.withOpacity(.08),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF43C2BD)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moduleCardV2(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String moduleInfo,
    required Widget icon,
    required int avatarCount,
  }) {
    final textTheme = Theme.of(context).textTheme;
    const ink = Color(0xFF1A1C1C);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ink.withOpacity(.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              alignment: Alignment.center,
              child: SizedBox(
                width: 56,
                height: 56,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: icon,
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: ink),
          ),
          SizedBox(height: 6),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: ink.withOpacity(.65), height: 1.25),
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  moduleInfo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: ink.withOpacity(.55),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 10,
                      height: 10,
                      child: Stack(
                        children: [
                          for (int i = 0; i < (avatarCount > 1 ? 2 : avatarCount); i++)
                            Positioned(
                              left: i * 16.0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    AppAssets.studentAvatar,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '+$avatarCount',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: ink.withOpacity(.70),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _spotlightCard(
    BuildContext context, {
    required String name,
    required String badge,
    required String note,
  }) {
    final textTheme = Theme.of(context).textTheme;
    const ink = Color(0xFF1A1C1C);

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: ink.withOpacity(.06),
                backgroundImage: const AssetImage(AppAssets.leoimage),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: ink)),
                    SizedBox(height: 2),
                    Text(
                      badge,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF7B500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            note,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(color: ink.withOpacity(.70), height: 1.25),
          ),
        ],
      ),
    );
  }

  Widget _studentSpotlightSection(BuildContext context, List<StudentSpotlightCard> students) {
    final textTheme = Theme.of(context).textTheme;
    const ink = Color(0xFF1A1C1C);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ink.withOpacity(.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF7B500),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.star_rounded, size: 16, color: Colors.white),
              ),
              SizedBox(width: 10),
              Text(context.tr('Student Spotlight'),
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: ink),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (students.isEmpty)
            Text(context.tr('Top performers appear here once students begin lessons.'),
              style: textTheme.bodySmall?.copyWith(color: ink.withOpacity(.65)),
            )
          else
            SizedBox(
              height: 132,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (int i = 0; i < students.length; i++) ...[
                    if (i > 0) SizedBox(width: 12),
                    _spotlightCard(
                      context,
                      name: students[i].shortName,
                      badge: students[i].badgeLabel,
                      note: students[i].note,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

Widget _quickLinkCard(
  BuildContext context, {
  required String title,
  required String action,
  required String image,
  VoidCallback? onTap,
}) {
  final textTheme = Theme.of(context).textTheme;
  const ink = Color(0xFF1A1C1C);

  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ink.withOpacity(.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          /// IMAGE
          Image.asset(
            image,
            width: 56,
            height: 56,
            fit: BoxFit.contain,
          ),

          SizedBox(height: 8),

          /// TITLE
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: ink,
              height: 1.1,
              fontSize: 13,
            ),
          ),

          SizedBox(height: 6),

          /// ACTION
          Text(
            action,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0057B8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _activityTile(
    BuildContext context, {
    required String name,
    required String action,
    required String activityName,
    required String timeInfo,
    required _ActivityBadgeType badgeType,
    required String badgeText,
    required _ActivityAvatarType avatarType,
    String? avatarImage,
  }) {
    final textTheme = Theme.of(context).textTheme;
    const ink = Color(0xFF1A1C1C);

    final Color badgeColor;
    switch (badgeType) {
      case _ActivityBadgeType.xp:
        badgeColor = const Color(0xFF4CAF50);
        break;
      case _ActivityBadgeType.badge:
        badgeColor = const Color(0xFFF7B500);
        break;
      case _ActivityBadgeType.active:
        badgeColor = const Color(0xFF9C27B0);
        break;
    }

    final Widget avatar;
    switch (avatarType) {
      case _ActivityAvatarType.image:
        avatar = CircleAvatar(
          radius: 20,
          backgroundImage: avatarImage != null ? AssetImage(avatarImage) : null,
          backgroundColor: ink.withOpacity(.06),
        );
        break;
      case _ActivityAvatarType.group:
        avatar = Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F6F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.groups_rounded, color: Color(0xFF43C2BD), size: 20),
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ink.withOpacity(.06)),
      ),
      child: Row(
        children: [
          avatar,
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: ink)),
                SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: textTheme.bodySmall?.copyWith(color: ink.withOpacity(.70)),
                    children: [
                      TextSpan(text: '$action '),
                      TextSpan(
                        text: activityName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  timeInfo,
                  style: textTheme.labelSmall?.copyWith(
                    color: ink.withOpacity(.55),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badgeText,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }


}
