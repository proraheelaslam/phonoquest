// ignore_for_file: deprecated_member_use, prefer_const_constructors, sized_box_for_whitespace, unnecessary_const

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/navigation/student_journey_refresh.dart';
import '../dashboard/data/student_learning_adventures_repository.dart';
import '../dashboard/data/student_home_models.dart';
import 'adventure_module_ui.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/dashboard_bottom_nav_bar.dart';
import '../../core/l10n/app_language_controller.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({
    super.key,
    this.embeddedInShell = false,
    this.isActive = true,
  });

  final bool embeddedInShell;
  final bool isActive;

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> with WidgetsBindingObserver {
  final _adventuresRepo = StudentLearningAdventuresRepository();
  LearningAdventuresPayload? _payload;
  bool _loading = true;
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    StudentJourneyRefresh.tick.addListener(_onExternalRefreshRequest);
    _loadAdventures();
  }

  void _onExternalRefreshRequest() {
    if (!mounted || !widget.isActive) return;
    _loadAdventures(silent: true);
  }

  @override
  void dispose() {
    StudentJourneyRefresh.tick.removeListener(_onExternalRefreshRequest);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(JourneyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadAdventures(silent: true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.isActive) {
      _loadAdventures(silent: true);
    }
  }

  Future<void> _loadAdventures({bool silent = false}) async {
    if (!silent) {
      setState(() => _loading = true);
    }
    try {
      final payload = await _adventuresRepo.fetchAdventures();
      if (!mounted) return;
      setState(() {
        _payload = payload;
        _coins = payload.coins;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _weeklyGoalRatio {
    final pct = _payload?.weeklyQuestGoalPct ?? 0;
    return (pct / 100).clamp(0.0, 1.0);
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
      child: RefreshIndicator(
        onRefresh: _loadAdventures,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppScaffold.pageScrollPadding(
            context,
            horizontal: 8,
            top: 8,
            clearBottomNav: true,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
         Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(247, 205, 135, 1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(AppAssets.starimage, width: 12, height: 12),
                          SizedBox(width: 6),
                          Text('$_coins', style: textTheme.labelLarge),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.notifications),
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                  ],
                ),

                Text(
                  'Journey',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),

            SizedBox(height: 0),

            Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// LEFT TEXT
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                             Text(context.tr('Learning\nAdventures'),
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800, // ExtraBold
                                  fontSize: 24,
                                  height: 1.2,
                                  color: const Color.fromRGBO(21, 21, 21, 1),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(context.tr('Pick a quest and start your journey'),
                                style: GoogleFonts.lexend(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 12,
                                  color: const Color.fromRGBO(21, 21, 21, 1),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// RIGHT ICONS
                       Stack(
                          clipBehavior: Clip.none,
                          children: [
                            /// BACK IMAGE
                            Transform.rotate(
                              angle: -0.2,
                              child: SizedBox(
                                height: 70,
                                width: 70,
                                child: Image.asset(
                                  AppAssets.awardstarimage,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            /// FRONT IMAGE
                            Positioned(
                              left: 30,
                              child: Transform.rotate(
                                angle: 0.2,
                                child: SizedBox(
                                  height: 70,
                                  width: 70,
                                  child: Image.asset(
                                    AppAssets.bookimage,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          SizedBox(height: 10),

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
                                child: Stack(
                                  children: [
                                    /// 🔹 MAIN CONTENT
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(context.tr('Progress Tracking'),
                                          style: textTheme.headlineSmall?.copyWith(
                                            color: Colors.black.withOpacity(.90),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),

                                        SizedBox(height: 6),

                                        Text(context.tr('See growth over time with clear progress tools.'),
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: Colors.black.withOpacity(.70),
                                            height: 1.0,
                                          ),
                                        ),

                                        SizedBox(height: 14),

                                        /// 🔹 WEEKLY GOAL ROW (CLEAN)
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(context.tr('Weekly Quest Goal'),
                                                style: textTheme.labelMedium?.copyWith(
                                                  color: Colors.black.withOpacity(.70),
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${((_payload?.weeklyQuestGoalPct ?? 0).clamp(0, 100))}%',
                                              style: textTheme.labelMedium?.copyWith(
                                                color: Colors.black.withOpacity(.70),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 8),

                                        /// 🔹 PROGRESS BAR
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(999),
                                          child: LinearProgressIndicator(
                                            value: _weeklyGoalRatio,
                                            minHeight: 10,
                                            backgroundColor: const Color(0xFF32B4AE),
                                            valueColor: const AlwaysStoppedAnimation<Color>(
                                              Color(0xFFF7C653),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    /// 🔹 TOP RIGHT FLOATING IMAGE (FIXED POSITION)
                                    Positioned(
                                      top: 5,
                                      right: 0,
                                      child: Image.asset(
                                        AppAssets.progessimage,
                                        height: 50,
                                        width: 50,
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
                              onTap: () {
                                final currentRoute =
                                    ModalRoute.of(context)?.settings.name;
                                if (currentRoute != AppRouter.progress) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRouter.progress,
                                  );
                                }
                              },
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
                                      AppAssets.progressimage,
                                      height: 24,
                                      width: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(context.tr('View Full Report'),
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

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_payload == null || _payload!.modules.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
              child: Center(
                child: Text(
                  context.tr('Could not load learning adventures.'),
                  style: textTheme.bodyMedium,
                ),
              ),
            )
          else ...[
            SizedBox(height: 10),
            ...buildAdventureModuleGrid(context, _payload!.modules),
          ],

          SizedBox(height: 10),

          // 🏆 GOLDEN EAR AWARD
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
                      Text(context.tr('Rewards & Motivation'),
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      Text(context.tr('Celebrate effort with stars,\ntrophies, and badges.'),
                        style: textTheme.bodyMedium?.copyWith(height: 1.25),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text(context.tr('Claim Reward'),
                            style: textTheme.labelLarge?.copyWith(
                              color: const Color(0xFF8C6A1A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Center(
                              child: Text(
                                '12',
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF8C6A1A),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Center(
                              child: Image.asset(
                                  AppAssets.starperformenceimage,
                                  width: 12,
                                  height: 12,
                                  fit: BoxFit.contain,
                                ),
                            ),
                          ),
                        ],
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
                      AppAssets.rewardimage,
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
          ),
        ],
          ),
        ),
      ),
    );
  }


}
