// ignore_for_file: deprecated_member_use, prefer_const_constructors, camel_case_types

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import 'package:phonoquest_signup_flow/shared/widgets/parent_bottom_nav_bar.dart';
import '../../../../../core/auth/current_user_storage.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../data/parent_dashboard_models.dart';
import '../../../data/parent_dashboard_repository.dart';
import '../../../../../shared/widgets/parent_notification_bell.dart';
import 'parent_link_child_helper.dart';
import 'parent_tab_refresh_coordinator.dart';
import '../../../../../core/l10n/app_language_controller.dart';

class parentsDashboardScreen extends StatefulWidget {
  const parentsDashboardScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<parentsDashboardScreen> createState() => _ParentsDashboardScreenState();
}

class _ParentsDashboardScreenState extends State<parentsDashboardScreen>
    implements ParentShellTab {
  final _repo = ParentDashboardRepository();
  late Future<ParentDashboardPayload> _dashboardFuture;
  late Future<String> _displayNameFuture;
  bool _reloadInFlight = false;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _repo.fetchDashboard();
    _displayNameFuture = _parentName();
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
      await _reloadDashboard();
    } finally {
      _reloadInFlight = false;
    }
  }

  Future<void> _reloadDashboard() async {
    setState(() {
      _dashboardFuture = _repo.fetchDashboard();
    });
    await _dashboardFuture;
  }

  Future<String> _parentName() async {
    final profile = await CurrentUserStorage.instance.readProfile();
    if (profile == null) return 'Parent';
    final display = profile.displayName.trim();
    if (display.isNotEmpty) return display;
    final merged = [profile.firstName, profile.lastName]
        .where((s) => s.trim().isNotEmpty)
        .join(' ')
        .trim();
    return merged.isNotEmpty ? merged : 'Parent';
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
      child: FutureBuilder<ParentDashboardPayload>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final message = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Could not load dashboard.';
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
          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () => reloadFromShell(force: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppScaffold.pageScrollPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context, data),
                  SizedBox(height: 14),
                  _goalCard(data.todayGoal),
                  SizedBox(height: 14),
                  if (data.statCards.length >= 2)
                    Row(
                      children: [
                        Expanded(child: _statCardFromApi(data.statCards[0])),
                        SizedBox(width: 10),
                        Expanded(child: _statCardFromApi(data.statCards[1])),
                      ],
                    )
                  else if (data.statCards.isNotEmpty)
                    _statCardFromApi(data.statCards.first),
                  SizedBox(height: 18),
                  _sectionTitle(
                    'Weekly Progress',
                    trailing: data.weeklyProgressTrailing,
                    onTrailingTap: () => Navigator.pushReplacementNamed(
                      context,
                      AppRouter.parentsstatusscreen,
                    ),
                  ),
                  SizedBox(height: 10),
                  _progressChart(data.weeklyProgress),
                  SizedBox(height: 16),
                  _sectionTitle(
                    'Recent Milestones',
                    trailing: data.milestonesTrailing,
                    onTrailingTap: data.milestones.isEmpty
                        ? null
                        : () => Navigator.pushNamed(
                              context,
                              AppRouter.parentrecentquests,
                            ),
                  ),
                  SizedBox(height: 10),
                  _milestones(data.milestones),
                  SizedBox(height: 16),
                  _weeklyReports(data.weeklyReports),
                  SizedBox(height: 16),
                  _premiumCard(data.premium),
                  SizedBox(height: 14),
                  _parentingTip(data.parentingTip),
                  if (!data.childLinked) ...[
                    SizedBox(height: 12),
                    _linkChildBanner(data.childQuestCode),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, ParentDashboardPayload data) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 17,
          backgroundImage: AssetImage(AppAssets.teacherprofileimage),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('Welcome Back !'), style: GoogleFonts.lexend(fontSize: 10)),
              FutureBuilder<String>(
                future: _displayNameFuture,
                builder: (context, snapshot) => Text(
                  snapshot.data ?? 'Parent',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                data.childSubtitle,
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  color: const Color(0xFF717786),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        ParentNotificationBell(initialCount: data.unreadTeacherMessageCount),
      ],
    );
  }

  Widget _goalCard(TodayGoalCard goal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(232, 125, 147, 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pill(goal.pillLabel),
          SizedBox(height: 14),
          Text(
            goal.title,
            style: GoogleFonts.lexend(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            goal.description,
            style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              goal.progressLabel,
              style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: goal.progressValue,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(.25),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD21F)),
            ),
          ),
          SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFFFD21F),
                  child: Icon(Icons.star_rounded, color: Color(0xFFFF6F98)),
                ),
                SizedBox(width: 10),
                Text(
                  '${goal.totalPoints}',
                  style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 8),
                Text(context.tr('TOTAL POINTS'),
                  style: GoogleFonts.lexend(fontSize: 10, letterSpacing: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _statCardFromApi(ParentStatCard card) {
    final isTime = card.key == 'time';
    return _smallStatCard(
      icon: isTime ? Icons.access_time_rounded : Icons.text_fields_rounded,
      title: card.title,
      value: card.value,
      subtitle: card.subtitle,
      iconColor: isTime ? const Color(0xFF3D7CFF) : const Color(0xFFFFA726),
      trendPositive: card.trendPositive,
    );
  }

  Widget _smallStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color iconColor,
    required bool trendPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor.withOpacity(.12),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.lexend(fontSize: 9)),
                Text(
                  value,
                  style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.lexend(
                    fontSize: 8,
                    color: trendPositive ? Colors.green : const Color(0xFF717786),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title, {
    String? trailing,
    VoidCallback? onTrailingTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              trailing,
              style: GoogleFonts.lexend(
                fontSize: 11,
                color: const Color(0xFFFF6F98),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Color _barColor(String token) {
    switch (token) {
      case 'gold':
        return const Color(0xFFFFB800);
      case 'blue_light':
        return const Color(0xFF9BC3E9);
      case 'blue':
        return const Color(0xFF0067C9);
      case 'gray':
      default:
        return const Color(0xFFE8ECEF);
    }
  }

  Widget _progressChart(List<WeeklyProgressBar> bars) {
    if (bars.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(context.tr('No weekly activity yet'),
          style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF717786)),
        ),
      );
    }

    return Container(
      height: 190,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bars.map((bar) {
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: bar.barHeight,
                  width: 38,
                  decoration: BoxDecoration(
                    color: _barColor(bar.colorToken),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                SizedBox(height: 8),
                Text(bar.dayLabel, style: GoogleFonts.lexend(fontSize: 9)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _milestones(List<ParentMilestone> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(context.tr('Milestones will appear when your child completes lessons.'),
          style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF717786)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: items
            .map(
              (m) => _MilestoneTile(
                icon: _milestoneIcon(m.icon),
                iconColor: _milestoneColor(m.icon),
                title: m.title,
                subtitle: m.subtitle,
                date: m.dateLabel,
              ),
            )
            .toList(),
      ),
    );
  }

  IconData _milestoneIcon(String key) {
    switch (key) {
      case 'book':
        return Icons.menu_book_rounded;
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'trophy':
      default:
        return Icons.emoji_events_rounded;
    }
  }

  Color _milestoneColor(String key) {
    switch (key) {
      case 'book':
        return const Color(0xFF8DBDFF);
      case 'fire':
        return const Color(0xFF69F282);
      case 'trophy':
      default:
        return const Color(0xFFFFB800);
    }
  }

  Widget _weeklyReports(List<WeeklyReportItem> reports) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize_rounded, color: Color(0xFFFF6F98)),
              SizedBox(width: 8),
              Text(context.tr('Weekly Reports'),
                style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (reports.isEmpty)
            Text(context.tr('Reports will be generated after your child practices.'),
              style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF717786)),
            )
          else
            ...reports.expand((r) sync* {
              yield _reportTile(r.periodLabel, r.subtitle);
              yield SizedBox(height: 10);
            }),
          SizedBox(height: 4),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(
              context,
              AppRouter.parentsreportsscreen,
            ),
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFF6F98)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(context.tr('Browse Archive'),
                style: GoogleFonts.lexend(
                  color: const Color(0xFFFF6F98),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportTile(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.article_outlined, color: Color(0xFF2C7BE5)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '$title\n$subtitle',
              style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.download_for_offline_outlined, color: Color(0xFF43C2BD)),
        ],
      ),
    );
  }

  Widget _premiumCard(PremiumPlanCard premium) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await Navigator.pushNamed(context, AppRouter.subscription);
          if (!mounted) return;
          await _reloadDashboard();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF19B6D2), Color(0xFF25A9B1)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.diamond_rounded, color: Colors.pinkAccent, size: 54),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  '${premium.title}\n${premium.description}\n\n${premium.actionLabel}',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  Widget _parentingTip(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF7DF28A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '💡 Parenting Tip\n\n$text',
        style: GoogleFonts.lexend(fontSize: 12, height: 1.45),
      ),
    );
  }

  Widget _linkChildBanner(String? questCode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF6F98)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('Connect your child'),
            style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            questCode != null
                ? 'Add Quest ID $questCode (or child email) in Account Details to sync live progress.'
                : context.tr("Add your child's Quest ID, email, or name in settings to sync live progress."),
            style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF717786)),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              final linked = await openParentLinkChildAccount(context);
              if (linked == true) await reloadFromShell(force: true);
            },
            child: Text(context.tr('Link Child Account')),
          ),
        ],
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String date;

  const _MilestoneTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: iconColor,
            child: Icon(icon, color: Colors.black, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '$title\n$subtitle',
              style: GoogleFonts.lexend(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          Text(date, style: GoogleFonts.lexend(fontSize: 9)),
        ],
      ),
    );
  }
}
