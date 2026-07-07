// ignore_for_file: camel_case_types, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import 'package:phonoquest_signup_flow/shared/widgets/parent_bottom_nav_bar.dart';
import 'package:phonoquest_signup_flow/core/network/api_exception.dart';
import 'package:phonoquest_signup_flow/features/auth/data/parent_messages_models.dart';
import 'package:phonoquest_signup_flow/features/auth/data/parent_messages_repository.dart';
import '../../../../../core/l10n/app_language_controller.dart';

class parentNotificationScreen extends StatefulWidget {
  const parentNotificationScreen({super.key});

  @override
  State<parentNotificationScreen> createState() => _parentNotificationScreenState();
}

class _parentNotificationScreenState extends State<parentNotificationScreen> {
  final _repo = ParentMessagesRepository();
  late Future<List<ParentInboxMessage>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadInbox();
  }

  Future<List<ParentInboxMessage>> _loadInbox() async {
    final items = await _repo.fetchInbox();
    await _repo.markAllRead();
    return items;
  }

  void _reload() {
    setState(() => _future = _loadInbox());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.dashboardimage,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  SizedBox(height: 28),
                  Expanded(
                    child: FutureBuilder<List<ParentInboxMessage>>(
                      future: _future,
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
                                  snapshot.error is ApiException
                                      ? (snapshot.error as ApiException).message
                                      : 'Could not load messages.',
                                ),
                                TextButton(onPressed: _reload, child: Text(context.tr('Retry'))),
                              ],
                            ),
                          );
                        }
                        final items = snapshot.data ?? const [];
                        if (items.isEmpty) {
                          return Center(
                            child: Text(context.tr('No teacher messages yet.')),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () async => _reload(),
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            itemCount: items.length,
                            separatorBuilder: (_, __) => SizedBox(height: 14),
                            itemBuilder: (context, index) => _messageCard(items[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: parentDashboardBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          final targetRoute = parentDashboardBottomNavBar.routeFromIndex(index);
          Navigator.pushReplacementNamed(context, targetRoute);
        },
      ),
    );
  }

  Widget _header(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Image.asset(AppAssets.backimage, width: 22, height: 22),
              ),
            ),
          ),
          Center(
            child: Text(
              'Messages',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageCard(ParentInboxMessage item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA).withOpacity(.95),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
              ),
              Text(
                item.timeLabel,
                style: GoogleFonts.lexend(fontSize: 10, color: const Color(0xFF64748B)),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'From ${item.teacherName} • ${item.messageTypeLabel}',
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF53C8C1),
            ),
          ),
          SizedBox(height: 8),
          Text(
            item.body,
            style: GoogleFonts.lexend(
              fontSize: 12,
              height: 1.45,
              color: const Color(0xFF414754),
            ),
          ),
        ],
      ),
    );
  }
}
