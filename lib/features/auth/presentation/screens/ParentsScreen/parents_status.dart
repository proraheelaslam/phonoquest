// ignore_for_file: deprecated_member_use, prefer_const_constructors, camel_case_types

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import 'package:phonoquest_signup_flow/shared/widgets/parent_bottom_nav_bar.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../shared/widgets/parent_notification_bell.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../data/parent_dashboard_repository.dart';
import '../../../data/parent_status_models.dart';
import '../../../../../core/l10n/app_language_controller.dart';
import 'widgets/parent_quest_tile.dart';
import 'parent_tab_refresh_coordinator.dart';

class parentsStatusScreen extends StatefulWidget {
  const parentsStatusScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<parentsStatusScreen> createState() => _ParentsStatusScreenState();
}

class _ParentsStatusScreenState extends State<parentsStatusScreen>
    implements ParentShellTab {
  final _repo = ParentDashboardRepository();
  late Future<ParentStatusPayload> _statusFuture;
  bool _reloadInFlight = false;

  @override
  void initState() {
    super.initState();
    _statusFuture = _repo.fetchStatus();
  }

  @override
  Future<void> reloadFromShell({bool force = false}) async {
    if (_reloadInFlight) return;
    _reloadInFlight = true;
    try {
      if (force) {
        ParentTabRefreshCoordinator.prepareForcedReload();
      } else {
        ParentTabRefreshCoordinator.invalidateParentDashboardCache();
      }
      await _reload();
    } finally {
      _reloadInFlight = false;
    }
  }

  Future<void> _reload() async {
    setState(() {
      _statusFuture = _repo.fetchStatus();
    });
    await _statusFuture;
  }

  Future<void> _linkChildAccount() async {
    final updated = await AppRouter.pushLinkChildAccount(context);
    if (!mounted) return;
    if (updated == true) {
      ParentTabRefreshCoordinator.prepareForcedReload();
      await _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Child account linked. Refreshing status…')),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  String _moduleImage(String assetKey) {
    switch (assetKey) {
      case 'vowelsimage':
        return AppAssets.vowelsimage;
      case 'exploreimage':
        return AppAssets.exploreimage;
      case 'phonicsimage':
        return AppAssets.phonicsimage;
      case 'journeyimage':
      default:
        return AppAssets.journeyimage;
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
      bottomNavigationBar: widget.embeddedInShell
          ? null
          : parentDashboardBottomNavBar(
              currentIndex: parentDashboardBottomNavBar.indexFromRoute(
                ModalRoute.of(context)?.settings.name,
              ),
              onTap: (index) {
                final targetRoute = parentDashboardBottomNavBar.routeFromIndex(index);
                final currentRoute = ModalRoute.of(context)?.settings.name;
                if (targetRoute != currentRoute) {
                  Navigator.pushReplacementNamed(context, targetRoute);
                }
              },
            ),
      child: FutureBuilder<ParentStatusPayload>(
        future: _statusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final message = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Could not load status.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message, textAlign: TextAlign.center),
                    SizedBox(height: 12),
                    TextButton(onPressed: _reload, child: Text(context.tr('Retry'))),
                  ],
                ),
              ),
            );
          }
          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () => reloadFromShell(force: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppScaffold.pageScrollPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context, data.header),
                  if (!data.header.childLinked) ...[
                    SizedBox(height: 12),
                    _linkChildStepsCard(context),
                  ],
                  SizedBox(height: 16),
                  _journeyCard(data),
                  SizedBox(height: 14),
                  _soundMasteryCard(data.soundMastery),
                  SizedBox(height: 14),
                  _currentFocusCard(context, data),
                  SizedBox(height: 18),
                  _sectionHeader(
                    data.recentQuestsTrailing,
                    showTrailing: data.header.childLinked &&
                        (data.recentQuests.isNotEmpty || data.recentQuestsTotal > 0),
                    onTrailingTap: () => Navigator.pushNamed(
                      context,
                      AppRouter.parentrecentquests,
                    ),
                  ),
                  SizedBox(height: 10),
                  _recentQuestsList(data.recentQuests),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _linkChildStepsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color.fromRGBO(255, 111, 152, 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('Link your child (3 steps)'),
            style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          _linkStep('1', 'Your child must have a Student account in PhonoQuest.'),
          _linkStep('2', 'Get their Quest ID: login email, PQ code (e.g. PQ12), or display name.'),
          _linkStep('3', 'Tap Link Child Account — enter Quest ID, verify, and save.'),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _linkChildAccount(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(85, 200, 195, 1),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(context.tr('Link Child Account'),
                style: GoogleFonts.lexend(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: const Color.fromRGBO(0, 117, 255, 1),
            child: Text(
              number,
              style: GoogleFonts.lexend(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lexend(fontSize: 11, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, ChildStatusHeader header) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundImage: AssetImage(AppAssets.studentimage),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      header.childName,
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (header.childLinked) ...[
                    SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                  ],
                ],
              ),
              Text(
                header.levelSubtitle,
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  color: const Color.fromRGBO(70, 75, 85, 1),
                ),
              ),
            ],
          ),
        ),
        const ParentNotificationBell(iconSize: 24),
      ],
    );
  }

  Widget _journeyCard(ParentStatusPayload data) {
    final journey = data.journey;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.header.introText,
          style: GoogleFonts.lexend(
            fontSize: 15,
            color: const Color.fromRGBO(113, 119, 134, 1),
          ),
        ),
        SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 202, 119, 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                journey.sectionLabel,
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  color: const Color.fromRGBO(0, 117, 255, 1),
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 10),
              Text(
                journey.title,
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                journey.description,
                style: GoogleFonts.lexend(fontSize: 13, height: 1.25),
              ),
              SizedBox(height: 14),
              Container(
                height: 58,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 231, 194, 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color.fromRGBO(255, 111, 152, 1),
                      child: Icon(Icons.trending_up_rounded, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '${journey.overallMasteryPct}%',
                      style: GoogleFonts.lexend(
                        fontSize: 24,
                        color: const Color.fromRGBO(255, 111, 152, 1),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 14),
                    Text(
                      journey.masteryLabel,
                      style: GoogleFonts.lexend(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _soundMasteryCard(SoundMasteryCard card) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Color.fromRGBO(230, 230, 230, 1),
            child: Icon(Icons.castle_rounded, color: Colors.brown, size: 30),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusPill(card.statusLabel, card.statusTone),
                SizedBox(height: 5),
                Text(
                  card.title,
                  style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text(card.subtitle, style: GoogleFonts.lexend(fontSize: 11)),
                SizedBox(height: 12),
                if (card.items.isEmpty)
                  Text(context.tr('No mastery data yet.'),
                    style: GoogleFonts.lexend(fontSize: 11, color: const Color(0xFF717786)),
                  )
                else
                  Row(
                    children: card.items
                        .map(
                          (item) => _masteryItem(
                            item.label,
                            '${item.percent}%',
                            _masteryColor(item.percent),
                            _trendIcon(item.trendIcon),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _masteryColor(int pct) {
    if (pct >= 80) return const Color.fromRGBO(255, 111, 152, 1);
    if (pct >= 50) return const Color.fromRGBO(255, 184, 0, 1);
    return Colors.black;
  }

  IconData _trendIcon(String key) {
    switch (key) {
      case 'check':
        return Icons.check_circle;
      case 'up':
        return Icons.arrow_upward;
      default:
        return Icons.sync;
    }
  }

  Widget _statusPill(String label, String tone) {
    Color textColor = const Color.fromRGBO(0, 150, 75, 1);
    if (tone == 'unlinked') {
      textColor = const Color.fromRGBO(113, 119, 134, 1);
    } else if (tone == 'getting_started') {
      textColor = const Color.fromRGBO(255, 140, 0, 1);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(245, 245, 245, 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.lexend(
          fontSize: 8,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _masteryItem(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10,
              color: const Color.fromRGBO(113, 119, 134, 1),
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 4),
              Icon(icon, size: 12, color: color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _currentFocusCard(BuildContext context, ParentStatusPayload data) {
    final focus = data.currentFocus;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -28,
            child: Container(
              width: 135,
              height: 135,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(255, 248, 220, 1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('Current Focus'),
                style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                focus.description.isNotEmpty
                    ? focus.description
                    : 'Recommended practice areas.',
                style: GoogleFonts.lexend(fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      _moduleImage(focus.imageAsset),
                      width: 92,
                      height: 92,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      focus.moduleTitle,
                      style: GoogleFonts.lexend(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color.fromRGBO(0, 117, 255, 1),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      focus.focusDetail,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(fontSize: 12),
                    ),
                    SizedBox(height: 14),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (!data.header.childLinked) {
                          _linkChildAccount();
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Encourage ${data.header.childName} to practice ${focus.moduleTitle}.',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 48,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(85, 200, 195, 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          focus.ctaLabel,
                          style: GoogleFonts.lexend(fontWeight: FontWeight.w800),
                        ),
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

  Widget _sectionHeader(
    String trailing, {
    bool showTrailing = true,
    VoidCallback? onTrailingTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(context.tr('Recent Quests\nCompleted activities and milestones.'),
            style: GoogleFonts.lexend(
              fontSize: 12,
              height: 1.3,
              color: const Color.fromRGBO(80, 85, 95, 1),
            ),
          ),
        ),
        if (showTrailing && trailing.isNotEmpty)
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              context.tr(trailing),
              style: GoogleFonts.lexend(
                fontSize: 12,
                color: const Color.fromRGBO(255, 111, 152, 1),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _recentQuestsList(List<RecentQuestItem> quests) {
    if (quests.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(context.tr('Quest history will appear when your child completes lessons.'),
          style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF717786)),
        ),
      );
    }
    return Column(
      children: quests.map((q) => ParentQuestTile(quest: q)).toList(),
    );
  }
}
