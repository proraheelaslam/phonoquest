// ignore_for_file: deprecated_member_use, prefer_const_constructors, camel_case_types

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import 'package:phonoquest_signup_flow/shared/widgets/parent_bottom_nav_bar.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../data/parent_dashboard_repository.dart';
import '../../../data/parent_link_models.dart';
import '../../../../settings/data/repositories/profile_repository.dart';
import '../../../../../core/l10n/app_language_controller.dart';

class LinkChildAccountScreen extends StatefulWidget {
  const LinkChildAccountScreen({super.key});

  @override
  State<LinkChildAccountScreen> createState() => _LinkChildAccountScreenState();
}

class _LinkChildAccountScreenState extends State<LinkChildAccountScreen> {
  final _repo = ParentDashboardRepository();
  late final ProfileRepository _profileRepo;

  @override
  void initState() {
    super.initState();
    _profileRepo = ProfileRepository(apiClient: ApiClient());
    _loadExistingLink();
  }
  final _questCodeController = TextEditingController();
  final _childNameController = TextEditingController();

  bool _loadingProfile = true;
  bool _isVerifying = false;
  bool _isLinking = false;
  ChildLinkVerifyResult? _verifyResult;
  String? _errorMessage;

  @override
  void dispose() {
    _questCodeController.dispose();
    _childNameController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingLink() async {
    try {
      final payload = await _profileRepo.fetchMyProfile();
      if (!mounted) return;
      if (payload.status) {
        final code = payload.data.gradeLevel?.trim() ?? '';
        final nickname = payload.data.pendingChildDisplayName?.trim() ?? '';
        if (code.isNotEmpty) _questCodeController.text = code;
        if (nickname.isNotEmpty) _childNameController.text = nickname;
      }
    } catch (_) {
      // Non-blocking — parent can still enter Quest ID manually.
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _verify() async {
    final code = _questCodeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _verifyResult = null;
        _errorMessage = context.tr("Enter your child's Quest ID, email, or PQ code first.");
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
      _verifyResult = null;
    });

    try {
      final result = await _repo.verifyChildLink(code);
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _verifyResult = result;
        if (result.found && result.questCode != null && result.questCode!.isNotEmpty) {
          _questCodeController.text = code;
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Could not verify. Please try again.';
      });
    }
  }

  Future<void> _linkAndContinue() async {
    final code = _questCodeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Quest ID is required to link your child.');
      return;
    }

    if (_verifyResult?.found != true) {
      await _verify();
      if (_verifyResult?.found != true) return;
    }

    setState(() {
      _isLinking = true;
      _errorMessage = null;
    });

    try {
      final result = await _repo.linkChild(
        questCode: code,
        childDisplayName: _childNameController.text.trim().isNotEmpty
            ? _childNameController.text.trim()
            : null,
      );
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(context.tr('Child Linked!'),
            style: GoogleFonts.lexend(fontWeight: FontWeight.w800),
          ),
          content: Text(
            '${result.childName} is now connected. You can view live progress on Status and Home.',
            style: GoogleFonts.lexend(fontSize: 13, height: 1.4),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(
                backgroundColor: const Color.fromRGBO(85, 200, 195, 1),
              ),
              child: Text(context.tr('View Status'), style: GoogleFonts.lexend(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLinking = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLinking = false;
        _errorMessage = 'Could not link child. Please try again.';
      });
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
      bottomNavigationBar: parentDashboardBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          final targetRoute = parentDashboardBottomNavBar.routeFromIndex(index);
          if (targetRoute != AppRouter.parentsstatusscreen) {
            Navigator.pushReplacementNamed(context, targetRoute);
          }
        },
      ),
      child: _loadingProfile
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppScaffold.pageScrollPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  SizedBox(height: 20),
                  _heroCard(),
                  SizedBox(height: 18),
                  _stepsCard(),
                  SizedBox(height: 18),
                  _questIdField(),
                  SizedBox(height: 12),
                  _nicknameField(),
                  SizedBox(height: 12),
                  _verifyButton(),
                  if (_verifyResult != null) ...[
                    SizedBox(height: 12),
                    _verifyResultCard(_verifyResult!),
                  ],
                  if (_errorMessage != null) ...[
                    SizedBox(height: 12),
                    _errorBanner(_errorMessage!),
                  ],
                  SizedBox(height: 24),
                  _linkButton(),
                  SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(context.tr('Cancel'),
                        style: GoogleFonts.lexend(
                          color: const Color.fromRGBO(113, 119, 134, 1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context, false),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        Expanded(
          child: Column(
            children: [
              Text(context.tr('Link Child Account'),
                style: GoogleFonts.lexend(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(context.tr("Connect your child's student profile"),
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  color: const Color.fromRGBO(113, 119, 134, 1),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 40),
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              AppAssets.parentsinfoimage,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(context.tr("See mastery, sound progress, and recent quests once your child's account is linked."),
              style: GoogleFonts.lexend(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepsCard() {
    const steps = [
      'Your child needs a Student account in PhonoQuest.',
      'Ask for their login email, PQ code (e.g. PQ12), or profile name.',
      'Enter it below, verify, then tap Link & Continue.',
    ];

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
          Text(context.tr('How it works'),
            style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 10),
          for (var i = 0; i < steps.length; i++) ...[
            _stepRow('${i + 1}', steps[i]),
            if (i < steps.length - 1) SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _stepRow(String number, String text) {
    return Row(
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
          child: Text(text, style: GoogleFonts.lexend(fontSize: 11, height: 1.35)),
        ),
      ],
    );
  }

  Widget _questIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('Child Quest ID *'),
          style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _questCodeController,
            onChanged: (_) => setState(() {
              _verifyResult = null;
              _errorMessage = null;
            }),
            decoration: InputDecoration(
              hintText: context.tr('student@email.com or PQ42 or display name'),
              hintStyle: GoogleFonts.lexend(
                fontSize: 12,
                color: const Color.fromRGBO(113, 119, 134, 1),
              ),
              prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _nicknameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('Nickname (optional)'),
          style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _childNameController,
            decoration: InputDecoration(
              hintText: context.tr('How you call them in the app (e.g. Emma)'),
              hintStyle: GoogleFonts.lexend(
                fontSize: 12,
                color: const Color.fromRGBO(113, 119, 134, 1),
              ),
              prefixIcon: const Icon(Icons.child_care_outlined, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _verifyButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isVerifying || _isLinking ? null : _verify,
        icon: _isVerifying
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.verified_user_outlined, size: 20),
        label: Text(
          _isVerifying ? 'Checking…' : 'Verify Student Found',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color.fromRGBO(0, 117, 255, 1),
          side: const BorderSide(color: Color.fromRGBO(0, 117, 255, 1)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _verifyResultCard(ChildLinkVerifyResult result) {
    final found = result.found;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: found
            ? const Color.fromRGBO(225, 255, 235, 1)
            : const Color.fromRGBO(255, 249, 220, 1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: found
              ? const Color.fromRGBO(16, 185, 129, 1)
              : const Color.fromRGBO(245, 158, 11, 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            found ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            color: found
                ? const Color.fromRGBO(16, 185, 129, 1)
                : const Color.fromRGBO(245, 158, 11, 1),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              found
                  ? 'Found: ${result.childName ?? 'Student'}${result.questCode != null ? ' (${result.questCode})' : ''}'
                  : (result.hint ?? 'No student found. Check the Quest ID.'),
              style: GoogleFonts.lexend(fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        message,
        style: GoogleFonts.lexend(fontSize: 12, color: Colors.red.shade800),
      ),
    );
  }

  Widget _linkButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: _isLinking || _isVerifying ? null : _linkAndContinue,
        style: FilledButton.styleFrom(
          backgroundColor: const Color.fromRGBO(85, 200, 195, 1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLinking
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(context.tr('Link & Continue'),
                style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w800),
              ),
      ),
    );
  }
}
