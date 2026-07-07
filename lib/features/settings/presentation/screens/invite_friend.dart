// ignore_for_file: camel_case_types, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';

import '../../../../core/l10n/app_language_controller.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/dashboard_bottom_nav_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/invite_helper.dart';
import 'settings_navigation_helper.dart';

class InviteFriendScreen extends StatefulWidget {
  const InviteFriendScreen({super.key});

  @override
  State<InviteFriendScreen> createState() => _InviteFriendScreenState();
}

class _InviteFriendScreenState extends State<InviteFriendScreen> {
  late final ProfileRepository _profileRepository;
  String? _settingsReturnRoute;
  bool _loading = true;
  String _errorMessage = '';
  String _inviterName = '';
  String _inviteCode = '';
  String _inviteLink = '';

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepository(apiClient: ApiClient());
    _loadInviteDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.startsWith('/')) {
      _settingsReturnRoute = args;
    }
  }

  bool get _showStudentBottomNav =>
      _settingsReturnRoute == null || _settingsReturnRoute == AppRouter.settings;

  Future<void> _loadInviteDetails() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });
    try {
      final payload = await _profileRepository.fetchMyProfile();
      final profile = payload.data;
      final code = InviteHelper.codeForUserId(profile.userId);
      if (!mounted) return;
      if (code.isEmpty) {
        setState(() {
          _errorMessage = context.tr('Could not load your invite details.');
          _loading = false;
        });
        return;
      }
      setState(() {
        _inviterName = profile.primaryName;
        _inviteCode = code;
        _inviteLink = InviteHelper.signupLink(code);
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = context.tr('Could not load your invite details.');
        _loading = false;
      });
    }
  }

  Future<void> _copyText(String value, String successMessage) async {
    if (value.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMessage)),
    );
  }

  Future<void> _copyInviteMessage() async {
    final message = InviteHelper.shareMessage(
      inviterName: _inviterName,
      inviteCode: _inviteCode,
      inviteLink: _inviteLink,
      isSpanish: context.t.isSpanish,
    );
    await _copyText(message, context.tr('Invite message copied.'));
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
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _inviteCard(context),
                          SizedBox(height: 24),
                          Text(
                            context.tr('Share PhonoQuest with friends and family.'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1C1C),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            context.tr(
                              'Invite others to join PhonoQuest so they can learn and practice phonics together.',
                            ),
                            style: GoogleFonts.lexend(
                              fontSize: 12,
                              height: 1.7,
                              color: const Color(0xFF414754),
                            ),
                          ),
                          SizedBox(height: 22),
                          if (_loading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (_errorMessage.isNotEmpty)
                            _errorCard(context)
                          else ...[
                            _detailTile(
                              label: context.tr('Your Invite Code'),
                              value: _inviteCode,
                              onCopy: () => _copyText(
                                _inviteCode,
                                context.tr('Invite code copied.'),
                              ),
                            ),
                            SizedBox(height: 12),
                            _detailTile(
                              label: context.tr('Your Invite Link'),
                              value: _inviteLink,
                              onCopy: () => _copyText(
                                _inviteLink,
                                context.tr('Invite link copied.'),
                              ),
                            ),
                            SizedBox(height: 18),
                            PrimaryButton(
                              label: context.tr('Copy Invite Message'),
                              onTap: _copyInviteMessage,
                            ),
                          ],
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _showStudentBottomNav
          ? DashboardBottomNavBar(
              currentIndex: 3,
              onTap: (index) {},
            )
          : null,
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
                onTap: () async => navigateBackToSettings(
                  context,
                  returnRoute: _settingsReturnRoute,
                ),
                child: Image.asset(
                  AppAssets.backimage,
                  width: 22,
                  height: 22,
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              context.tr('Invite Friend'),
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

  Widget _inviteCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA).withOpacity(.95),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Image.asset(
            AppAssets.inviteimage,
            width: 58,
            height: 58,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 12),
          Text(
            context.tr('Invite a Friend'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1C1C),
            ),
          ),
          SizedBox(height: 6),
          Text(
            context.tr(
              'Share the learning journey with a new friend using your invite link or code.',
            ),
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 12,
              height: 1.5,
              color: const Color(0xFF414754),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _errorMessage,
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: Colors.red.shade900,
            ),
          ),
          SizedBox(height: 12),
          TextButton(
            onPressed: _loadInviteDetails,
            child: Text(context.tr('Retry')),
          ),
        ],
      ),
    );
  }

  Widget _detailTile({
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA).withOpacity(.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
              ),
              SizedBox(width: 8),
              TextButton(
                onPressed: onCopy,
                child: Text(context.tr('Copy')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
