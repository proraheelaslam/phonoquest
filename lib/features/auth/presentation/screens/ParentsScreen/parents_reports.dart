// ignore_for_file: deprecated_member_use, prefer_const_constructors, camel_case_types

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import 'package:phonoquest_signup_flow/shared/widgets/parent_bottom_nav_bar.dart';
import '../../../../../core/auth/auth_token_storage.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/config/app_config.dart';
import '../../../../../core/downloads/printable_downloader.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../shared/widgets/parent_notification_bell.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../data/parent_dashboard_repository.dart';
import '../../../data/parent_resources_models.dart';
import '../../../data/teacher_dashboard_repository.dart';
import 'widgets/parent_resource_hero.dart';
import 'parent_tab_refresh_coordinator.dart';
import '../../../../../core/l10n/app_language_controller.dart';

class parentsReportsScreen extends StatefulWidget {
  const parentsReportsScreen({
    super.key,
    this.embeddedInShell = false,
    this.forTeacher = false,
  });

  final bool embeddedInShell;
  final bool forTeacher;

  @override
  State<parentsReportsScreen> createState() => _ParentsReportsScreenState();
}

class _ParentsReportsScreenState extends State<parentsReportsScreen>
    implements ParentShellTab {
  final _parentRepo = ParentDashboardRepository();
  final _teacherRepo = TeacherDashboardRepository();
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  ParentResourcesPayload? _data;
  bool _loading = true;
  bool _reloadInFlight = false;
  String _selectedTab = 'all';
  bool _showAllPrintables = false;
  String? _downloadingPrintableId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadResources();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _loadResources();
    });
  }

  @override
  Future<void> reloadFromShell({bool force = false}) async {
    if (_reloadInFlight) return;
    await _loadResources(force: force);
  }

  Future<void> _loadResources({bool force = false}) async {
    if (_reloadInFlight) return;
    _reloadInFlight = true;
    if (force) {
      ParentTabRefreshCoordinator.prepareForcedReload();
    } else {
      ParentTabRefreshCoordinator.invalidateParentDashboardCache();
    }
    setState(() => _loading = true);
    try {
      final payload = widget.forTeacher
          ? await _teacherRepo.fetchResources(
              tab: _selectedTab,
              query: _searchController.text,
            )
          : await _parentRepo.fetchResources(
              tab: _selectedTab,
              query: _searchController.text,
            );
      if (!mounted) return;
      setState(() {
        _data = payload;
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
    } finally {
      _reloadInFlight = false;
    }
  }

  void _selectTab(String key) {
    if (_selectedTab == key) return;
    setState(() {
      _selectedTab = key;
      _showAllPrintables = false;
    });
    _loadResources();
  }

  String _assetPath(String key) {
    switch (key) {
      case 'playfullimage':
        return AppAssets.playfullimage;
      case 'playimage':
        return AppAssets.playimage;
      case 'bookimage':
        return AppAssets.bookimage;
      case 'journeyimage':
        return AppAssets.journeyimage;
      case 'vowelsimage':
        return AppAssets.vowelsimage;
      case 'phonicsimage':
        return AppAssets.phonicsimage;
      case 'goalimage':
        return AppAssets.goalimage;
      case 'wordimage':
        return AppAssets.wordimage;
      case 'exploreimage':
        return AppAssets.exploreimage;
      case 'parent_resource_reading_routine':
        return AppAssets.parentResourceReadingRoutine;
      case 'parentsinfoimage':
        return AppAssets.parentsinfoimage;
      case 'libraryimage':
        return AppAssets.libraryimage;
      case 'illustringimage':
        return AppAssets.illustringimage;
      case 'greatimage':
        return AppAssets.greatimage;
      case 'sunnyimage':
        return AppAssets.sunnyimage;
      default:
        return AppAssets.parentResourceReadingRoutine;
    }
  }

  Color _tipBackground(String token) {
    switch (token) {
      case 'yellow_soft':
        return const Color.fromRGBO(255, 249, 220, 1);
      case 'green_soft':
        return const Color.fromRGBO(225, 255, 235, 1);
      case 'blue_soft':
      default:
        return const Color.fromRGBO(230, 242, 255, 1);
    }
  }

  IconData _tipIcon(String key) {
    switch (key) {
      case 'hearing':
        return Icons.hearing_rounded;
      case 'groups':
        return Icons.groups_rounded;
      case 'schedule':
        return Icons.schedule_rounded;
      case 'lightbulb':
      default:
        return Icons.lightbulb_outline_rounded;
    }
  }

  void _openFeaturedDetail(FeaturedResource item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).padding.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ParentResourceHero(
                resourceId: item.id,
                imageAssetKey: item.imageAsset,
                isVideo: item.isVideo,
                height: 140,
              ),
              SizedBox(height: 14),
              Text(
                item.title,
                style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 6),
              Text(
                item.durationLabel,
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  color: const Color.fromRGBO(113, 119, 134, 1),
                ),
              ),
              SizedBox(height: 12),
              Text(
                item.body.isNotEmpty ? item.body : item.subtitle,
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  height: 1.45,
                  color: const Color.fromRGBO(80, 85, 95, 1),
                ),
              ),
              SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          item.isVideo
                              ? 'Opening "${item.title}" — video player coming soon.'
                              : 'Enjoy reading "${item.title}".',
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 117, 255, 1),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    item.isVideo ? 'Watch' : 'Continue Reading',
                    style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _promptPrintableUpgrade(PrintableResource item) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${item.title} is premium'),
        content: Text(
          item.lockReason ?? 'Upgrade your family plan to download this printable.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.tr('Not now'))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Navigator.pushNamed(context, AppRouter.subscription);
              if (!mounted) return;
              await _loadResources();
            },
            child: Text(context.tr('View plans')),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPrintable(PrintableResource item) async {
    if (_downloadingPrintableId != null) return;
    if (item.isLocked) {
      _promptPrintableUpgrade(item);
      return;
    }

    setState(() => _downloadingPrintableId = item.id);
    try {
      final token = await AuthTokenStorage.instance.readAccessToken();
      final path = item.downloadPath.startsWith('/')
          ? item.downloadPath
          : '/${item.downloadPath}';
      final url = '${AppConfig.apiBaseUrl}$path';
      final filename = 'phonoquest-${item.id.replaceAll('_', '-')}';

      await downloadPrintablePdf(
        url: url,
        filename: filename,
        headers: {
          'Accept': 'application/pdf',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.title} downloaded successfully.'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } on PrintableDownloadException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Could not download this chart. Please try again.')),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) setState(() => _downloadingPrintableId = null);
    }
  }

  void _showPrintableDetail(PrintableResource item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(_assetPath(item.imageAsset), width: 96, height: 96, fit: BoxFit.contain),
            SizedBox(height: 12),
            Text(
              item.title,
              style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 6),
            Text(
              item.fileLabel,
              style: GoogleFonts.lexend(fontSize: 11, color: const Color.fromRGBO(113, 119, 134, 1)),
            ),
            if (item.description.isNotEmpty) ...[
              SizedBox(height: 10),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(fontSize: 12, height: 1.4),
              ),
            ],
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _downloadPrintable(item);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 117, 255, 1),
                ),
                child: Text(context.tr('Download'), style: GoogleFonts.lexend(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      wrapInScrollView: false,
      bottomNavigationBar: widget.embeddedInShell || widget.forTeacher
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
      child: _loading && data == null
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadResources,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppScaffold.pageScrollPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(
                      context,
                      title: data?.pageTitle ?? 'Resource Library',
                      subtitle: data?.pageSubtitle ??
                          "Tools and guides to support your child's journey.",
                    ),
                    SizedBox(height: 14),
                    _searchBox(),
                    SizedBox(height: 12),
                    _tabs(data?.tabs ?? const []),
                    SizedBox(height: 14),
                    if (_loading)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    else if (data != null) ...[
                      if (data.featured.isNotEmpty) ...[
                        _sectionTitle(data.featuredSectionTitle),
                        SizedBox(height: 8),
                        for (final item in data.featured) ...[
                          _featuredCard(
                            item: item,
                            onTap: () => _openFeaturedDetail(item),
                          ),
                          SizedBox(height: 12),
                        ],
                      ],
                      if (data.printables.isNotEmpty) ...[
                        _sectionRow(
                          data.printablesSectionTitle,
                          data.printables.length > 4 && !_showAllPrintables ? 'View all' : '',
                          onAction: data.printables.length > 4 && !_showAllPrintables
                              ? () => setState(() => _showAllPrintables = true)
                              : null,
                        ),
                        SizedBox(height: 10),
                        if (data.printablesLockedMessage != null &&
                            data.printablesLockedMessage!.isNotEmpty &&
                            !data.isPremium) ...[
                          SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7E6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    data.printablesLockedMessage!,
                                    style: GoogleFonts.lexend(fontSize: 11, height: 1.35),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await Navigator.pushNamed(context, AppRouter.subscription);
                                    if (!mounted) return;
                                    await _loadResources();
                                  },
                                  child: Text(context.tr('Upgrade')),
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 8),
                        _printablesGrid(
                          _showAllPrintables
                              ? data.printables
                              : data.printables.take(4).toList(),
                        ),
                        SizedBox(height: 16),
                      ],
                      if (data.tips.isNotEmpty) ...[
                        _sectionTitle(data.tipsSectionTitle),
                        SizedBox(height: 10),
                        for (final tip in data.tips) ...[
                          _tipCard(
                            icon: _tipIcon(tip.icon),
                            bg: _tipBackground(tip.bgColor),
                            title: tip.title,
                            text: tip.text,
                          ),
                          SizedBox(height: 10),
                        ],
                      ],
                      if (data.featured.isEmpty &&
                          data.printables.isEmpty &&
                          data.tips.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: Colors.black.withOpacity(.2),
                                ),
                                SizedBox(height: 12),
                                Text(context.tr('No resources found'),
                                  style: GoogleFonts.lexend(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(context.tr('Try a different search or tab.'),
                                  style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    color: const Color.fromRGBO(113, 119, 134, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _header(BuildContext context, {required String title, required String subtitle}) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                title,
                style: GoogleFonts.lexend(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  color: const Color.fromRGBO(113, 119, 134, 1),
                ),
              ),
            ],
          ),
        ),
        _headerTrailing(context),
      ],
    );
  }

  Widget _headerTrailing(BuildContext context) {
    if (widget.forTeacher) {
      return IconButton(
        onPressed: () => Navigator.pushNamed(context, AppRouter.notifications),
        icon: Image.asset(
          AppAssets.teachernotificationimage,
          width: 22,
          height: 22,
          fit: BoxFit.contain,
        ),
      );
    }
    return const ParentNotificationBell();
  }

  Widget _searchBox() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(width: 8),
          const Icon(Icons.search_rounded, color: Color.fromRGBO(113, 119, 134, 1)),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.lexend(fontSize: 12),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: context.tr('Search resources, tips, or printables...'),
                hintStyle: GoogleFonts.lexend(
                  fontSize: 12,
                  color: const Color.fromRGBO(113, 119, 134, 1),
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () {
                _searchController.clear();
                _loadResources();
              },
            ),
        ],
      ),
    );
  }

  Widget _tabs(List<ResourceTab> tabs) {
    if (tabs.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final selected = tab.key == _selectedTab;
          return GestureDetector(
            onTap: () => _selectTab(tab.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? const Color.fromRGBO(0, 117, 255, 1) : Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tab.label,
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w800),
    );
  }

  Widget _sectionRow(String title, String action, {VoidCallback? onAction}) {
    return Row(
      children: [
        Expanded(child: _sectionTitle(title)),
        if (action.isNotEmpty)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action,
              style: GoogleFonts.lexend(
                fontSize: 10,
                color: const Color.fromRGBO(0, 117, 255, 1),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _featuredCard({required FeaturedResource item, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ParentResourceHero(
                resourceId: item.id,
                imageAssetKey: item.imageAsset,
                isVideo: item.isVideo,
                height: 132,
              ),
              SizedBox(height: 10),
              Text(
                item.title,
                style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  color: const Color.fromRGBO(80, 85, 95, 1),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    item.durationLabel,
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      color: const Color.fromRGBO(113, 119, 134, 1),
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: const Color.fromRGBO(0, 117, 255, 1),
                    child: Icon(
                      item.isVideo ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _printablesGrid(List<PrintableResource> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: .78,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _printableCard(
          item: item,
          onGet: () => _downloadPrintable(item),
          onPreview: () => _showPrintableDetail(item),
        );
      },
    );
  }

  Widget _printableCard({
    required PrintableResource item,
    required VoidCallback onGet,
    required VoidCallback onPreview,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPreview,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: item.isLocked ? 0.45 : 1,
                        child: Image.asset(
                          _assetPath(item.imageAsset),
                          width: 78,
                          height: 78,
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (item.isLocked) const Icon(Icons.lock_rounded, color: Color(0xFF6B7280)),
                    ],
                  ),
                ),
              ),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 3),
              Text(
                item.fileLabel,
                style: GoogleFonts.lexend(
                  fontSize: 9,
                  color: const Color.fromRGBO(113, 119, 134, 1),
                ),
              ),
              SizedBox(height: 6),
              GestureDetector(
                onTap: _downloadingPrintableId == item.id ? null : onGet,
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(245, 245, 245, 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _downloadingPrintableId == item.id
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          item.isLocked ? 'Upgrade' : '⇩  Get',
                          style: GoogleFonts.lexend(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: item.isLocked ? const Color(0xFFFF3B93) : null,
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

  Widget _tipCard({
    required IconData icon,
    required Color bg,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: Colors.white.withOpacity(.7),
            child: Icon(icon, size: 18, color: const Color.fromRGBO(0, 117, 255, 1)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: '$title\n',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: text,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
