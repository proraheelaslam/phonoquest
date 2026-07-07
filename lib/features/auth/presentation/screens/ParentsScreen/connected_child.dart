// ignore_for_file: prefer_const_constructors, camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../shared/constants/app_assets.dart';
import '../../../../../shared/widgets/phono_back_button.dart';
import '../../../../../shared/widgets/phono_shell.dart';
import '../../../../../shared/widgets/primary_button.dart';
import '../../../domain/parent_registration_draft.dart';
import '../../../../../core/l10n/app_language_controller.dart';

class ConnectedChildScreen extends StatefulWidget {
  const ConnectedChildScreen({super.key, this.draft});

  final ParentRegistrationDraft? draft;

  @override
  State<ConnectedChildScreen> createState() => _ConnectedChildScreenState();
}

class _ConnectedChildScreenState extends State<ConnectedChildScreen> {
  final _questCodeController = TextEditingController();
  final _childNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.draft == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Please complete your personal info first.'))),
        );
        Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _questCodeController.dispose();
    _childNameController.dispose();
    super.dispose();
  }

  void _goNext() {
    final base = widget.draft;
    if (base == null) return;

    final questCode = _questCodeController.text.trim();
    final childName = _childNameController.text.trim();

    if (questCode.isEmpty && childName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Enter a Quest ID to link a child, or add a new profile name.'))),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRouter.learningadventure,
      arguments: base.copyWith(
        linkedStudentQuestCode: questCode.isNotEmpty ? questCode : null,
        pendingChildDisplayName: childName.isNotEmpty ? childName : null,
        clearQuestCode: questCode.isEmpty,
        clearChildName: childName.isEmpty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                AppAssets.signUpBackground,
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: PhonoShell(
                stepLabel: '',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 245, 230, 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(context.tr('STEP 3 OF 4'),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color.fromRGBO(248, 118, 146, 1),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.4,
                                ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(context.tr('Connect with Child'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                        ),
                      ),
                      SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(context.tr('Link an existing profile by Quest ID, username, or email, or begin a new adventure.'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black.withOpacity(.55),
                                fontSize: 13,
                              ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(context.tr('Use Quest ID'),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                      ),
                      SizedBox(height: 14),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          controller: _questCodeController,
                          decoration: InputDecoration(
                            hintText: context.tr('e.g. PQ-ABC123'),
                            hintStyle: TextStyle(color: Colors.black.withOpacity(.32), fontSize: 14),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.vpn_key_outlined, size: 20, color: Colors.black.withOpacity(.42)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFF0C2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add, size: 20, color: Color(0xFFD4A017)),
                                ),
                                SizedBox(width: 10),
                                Text(context.tr('New Profile'),
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(context.tr("Create a new adventurer profile if they don't already have an account."),
                              style: TextStyle(fontSize: 12.5, color: Colors.black.withOpacity(.50), height: 1.4),
                            ),
                            SizedBox(height: 12),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                controller: _childNameController,
                                decoration: InputDecoration(
                                  hintText: context.tr("Child's display name"),
                                  hintStyle: TextStyle(color: Colors.black.withOpacity(.32), fontSize: 14),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.child_care_outlined, size: 20, color: Colors.black.withOpacity(.42)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      PrimaryButton(label: context.tr('NEXT'), onTap: _goNext),
                      SizedBox(height: 18),
                      Center(
                        child: PhonoBackButton(onTap: () => Navigator.pop(context)),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
