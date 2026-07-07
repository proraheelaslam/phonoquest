// ignore_for_file: deprecated_member_use, prefer_const_constructors, camel_case_types

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';

import '../../../../../core/l10n/app_language_controller.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../data/parent_dashboard_repository.dart';
import '../../../data/parent_status_models.dart';
import 'widgets/parent_quest_tile.dart';

class ParentRecentQuestsScreen extends StatefulWidget {
  const ParentRecentQuestsScreen({super.key});

  @override
  State<ParentRecentQuestsScreen> createState() => _ParentRecentQuestsScreenState();
}

class _ParentRecentQuestsScreenState extends State<ParentRecentQuestsScreen> {
  final _repo = ParentDashboardRepository();
  late Future<ParentRecentQuestsPayload> _questsFuture;

  @override
  void initState() {
    super.initState();
    _questsFuture = _repo.fetchRecentQuests();
  }

  Future<void> _reload() async {
    setState(() {
      _questsFuture = _repo.fetchRecentQuests();
    });
    await _questsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      wrapInScrollView: false,
      child: FutureBuilder<ParentRecentQuestsPayload>(
        future: _questsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final message = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Could not load recent quests.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    TextButton(onPressed: _reload, child: Text(context.tr('Retry'))),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _reload,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppScaffold.pageScrollPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              data.pageTitle,
                              style: GoogleFonts.lexend(fontSize: 17, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.pageSubtitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lexend(
                                fontSize: 11,
                                color: const Color.fromRGBO(113, 119, 134, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  if (data.childLinked && data.totalCount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${data.totalCount} ${data.totalCount == 1 ? 'activity' : 'activities'}',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        color: const Color.fromRGBO(113, 119, 134, 1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (!data.childLinked)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.tr('Link your child account to see quest history.'),
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: const Color(0xFF717786),
                        ),
                      ),
                    )
                  else if (data.quests.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.tr('Quest history will appear when your child completes lessons.'),
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: const Color(0xFF717786),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (final quest in data.quests) ParentQuestTile(quest: quest),
                      ],
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
