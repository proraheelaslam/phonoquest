// ignore_for_file: deprecated_member_use, prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/auth/current_user_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/router/app_router.dart';
import '../../data/student_home_models.dart';
import '../../data/student_home_repository.dart';
import '../../data/student_module_routes.dart';
import '../../../journey/adventure_module_ui.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/dashboard_bottom_nav_bar.dart';
import '../../../../shared/widgets/primary_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../core/l10n/app_language_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.embeddedInShell = false,
    this.isActive = true,
  });

  final bool embeddedInShell;
  final bool isActive;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  late Future<StudentHomePayload> _homeFuture;
  String _studentName = 'Student';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _homeFuture = StudentHomeRepository().fetchHome();
    _loadLocalUser();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _reloadDashboard();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.isActive) {
      _reloadDashboard();
    }
  }

  Future<void> _loadLocalUser() async {
    final profile = await CurrentUserStorage.instance.readProfile();
    if (!mounted || profile == null) return;
    final name = profile.displayName.trim().isNotEmpty
        ? profile.displayName.trim()
        : [profile.firstName, profile.lastName]
            .where((s) => s.trim().isNotEmpty)
            .join(' ')
            .trim();
    if (name.isEmpty) return;
    setState(() {
      _studentName = name;
    });
  }

  void _reloadDashboard() {
    ApiClient.clearRequestCache();
    setState(() {
      _homeFuture = StudentHomeRepository().fetchHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      bottomNavigationBar: widget.embeddedInShell
          ? null
          : DashboardBottomNavBar(
              currentIndex: DashboardBottomNavBar.indexFromRoute(ModalRoute.of(context)?.settings.name),
              onTap: (index) {
                final targetRoute = DashboardBottomNavBar.routeFromIndex(index);
                final currentRoute = ModalRoute.of(context)?.settings.name;
                if (targetRoute != currentRoute) {
                  Navigator.pushReplacementNamed(context, targetRoute);
                }
              },
            ),
      child: FutureBuilder<StudentHomePayload>(
        future: _homeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF475467)),
                  ),
                  SizedBox(height: 16),
                  TextButton(onPressed: _reloadDashboard, child: Text(context.tr('Retry'))),
                ],
              ),
            );
          }

          final home = snapshot.data!;
          final assignment = home.teacherAssignment;
          final active = home.activeModule;
          final resumeRoute = studentModuleRoute(
            assignment?.route ?? active.route,
          );
          final adventures = home.adventures;
          final primaryAdventures = adventures.length >= 2
              ? adventures.take(2).toList()
              : adventures;
          final promoModule = adventures.firstWhere(
            (m) => m.code == 'vowel_learning',
            orElse: () => adventures.isNotEmpty
                ? adventures.last
                : const AdventureModule(
                    code: 'vowel_learning',
                    title: 'Vowel Volcano',
                    description: 'Conquer the world of short and long vowels.',
                    linkLabel: 'Discover',
                    route: 'vowelslearning',
                  ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(AppAssets.profileimage,),
                        child: Icon(Icons.person_rounded, size: 20), // fallback
                      ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('Welcome Back!'), style: textTheme.bodySmall),
                    Text(_studentName, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
               color: Color.fromRGBO(247, 205, 135, 1),                  borderRadius: BorderRadius.circular(999),
                ),
              child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                         AppAssets.starimage,
                          width: 12,
                          height: 12,
                          fit: BoxFit.contain,
                         // color: Colors.amber, // 👈 yahan add hoga
                        ),
                        SizedBox(width: 6),
                        Text(
                          '${home.coins}',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
              ),
              SizedBox(width: 10),
              _notificationBell(context, count: home.pendingAssignmentCount),
            ],
          ),
          SizedBox(height: 14),

          if (assignment != null) ...[
            _teacherAssignmentBanner(context, assignment),
            SizedBox(height: 14),
          ],

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // ✅ TEAL SECTION (ALL SIDES ROUNDED)
                      Container(
                       margin: EdgeInsets.zero, // 👈 IMPORTANT (bottom radius visible)
                        decoration: BoxDecoration(
                          color: const Color(0xFF43C2BD),
                          borderRadius: BorderRadius.circular(12), // 👈 all sides
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(context.tr(assignment != null ? 'TEACHER ASSIGNMENT' : 'ACTIVE MODULE'),
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.black.withOpacity(.72),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .6,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                active.title,
                                style: textTheme.headlineSmall?.copyWith(
                                  color: Colors.black.withOpacity(.90),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                active.message,
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
                                    '${active.progressPct.clamp(0, 100)}%',
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
                                  value: (active.progressPct.clamp(0, 100) / 100),
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
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), // left/right/bottom only
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
                              onTap: () => Navigator.pushNamed(context, resumeRoute),
                              child: Container(
                                width: double.infinity,
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only( // 👈 FIXED
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
                                   AppAssets.playimage, // apni image ka path
                                    height: 24,
                                    width: 24,

                                  ),
                                    SizedBox(width: 8),
                                    Text(
                                      active.ctaLabel.toUpperCase(),
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
                        crossAxisAlignment: CrossAxisAlignment.center, // 👈 vertical center
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
                              mainAxisAlignment: MainAxisAlignment.center, // 👈 text center align
                              children: [
                                Text(context.tr('Daily Goal'),
                                  style: textTheme.labelMedium?.copyWith(fontSize: 7),
                                ),
                                Text(
                                  home.dailyMinutesLabel.isNotEmpty ? home.dailyMinutesLabel : '—',
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
                   color: Colors.white, // 👈 background color
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
                                home.wordsMasteredLabel.isNotEmpty ? home.wordsMasteredLabel : '—',
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
           padding: const EdgeInsets.only( left: 7, right: 0),
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
                    padding: const EdgeInsets.only(top: 12), // 👈 top space
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRouter.journey),
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
          if (primaryAdventures.isNotEmpty)
            Row(
              children: [
                for (var i = 0; i < primaryAdventures.length; i++) ...[
                  if (i > 0) SizedBox(width: 12),
                  Expanded(
                    child: buildAdventureModuleCard(context, module: primaryAdventures[i]),
                  ),
                ],
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

                          // 🖼 IMAGE SECTION (separate spacing)
                          SizedBox(
                            width: 88,
                            height: 88,
                            child: Image.asset(
                              AppAssets.vowelimage,
                              fit: BoxFit.contain,
                            ),
                          ),

                          SizedBox(width: 14),

                          // 📝 TEXT SECTION (separate spacing)
                          Expanded(
                            child: SizedBox(
                              height: 88,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      promoModule.title,
                                      style: const TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1C1C),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      promoModule.description,
                                      style: textTheme.bodySmall,
                                    ),
                                    SizedBox(height: 14),
                                    GestureDetector(
                                      onTap: () => onAdventureModuleTap(context, promoModule),
                                      child: Text(
                                      promoModule.isLocked
                                          ? '${promoModule.upgradeLabel ?? context.tr('Upgrade')}  →'
                                          : '${promoModule.linkLabel}  →',
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
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 👈 balanced
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
                                            AppAssets.minimage, // 👈 apni image path
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
                                            AppAssets.secimage, // 👈 apni image path
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
                          onTap: () => Navigator.pushNamed(context, resumeRoute),
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
                                Text(
                                  active.ctaLabel.toUpperCase(),
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

                      Material(
                color: const Color.fromRGBO(255, 191, 0, 0.2),
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.pushNamed(context, AppRouter.rewards),
                  child: Container(
                    padding: const EdgeInsets.all(15),
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
                  ),
                ),
              )
        ],
      );
    },
  ),
    );
  }

  Widget _teacherAssignmentBanner(
    BuildContext context,
    TeacherAssignmentCard assignment,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final teacher = assignment.teacherName ?? context.tr('Your teacher');
    final route = studentModuleRoute(assignment.route);
    return PrimaryCard(
      color: const Color(0xFFFFF4F8),
      onTap: () => Navigator.pushNamed(context, route),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(AppAssets.forestimage, width: 42, height: 42),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.tr('New assignment from')} $teacher',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  assignment.moduleTitle,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (assignment.teacherNote != null &&
                    assignment.teacherNote!.trim().isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    assignment.teacherNote!.trim(),
                    style: textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 8),
                Text(
                  context.tr('Start Quest  ->'),
                  style: textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF2F80ED),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationBell(BuildContext context, {required int count}) {
    final icon = const Icon(Icons.notifications_none_rounded);
    return IconButton(
      onPressed: () => Navigator.pushNamed(context, AppRouter.notifications),
      icon: count > 0
          ? Badge(
              label: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
              ),
              backgroundColor: const Color(0xFFEF4444),
              child: icon,
            )
          : icon,
    );
  }
}
