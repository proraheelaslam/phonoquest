// ignore_for_file: deprecated_member_use, prefer_const_constructors, sized_box_for_whitespace, camel_case_types, unused_import

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import 'package:phonoquest_signup_flow/shared/widgets/teacher_bottom_nav_bar.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/class_creation_draft.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/dashboard_bottom_nav_bar.dart';
import '../../../../shared/widgets/primary_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../core/l10n/app_language_controller.dart';

class choseYourClasseScreen extends StatefulWidget {
  const choseYourClasseScreen({super.key, this.draft});

  final ClassCreationDraft? draft;

  @override
  State<choseYourClasseScreen> createState() => _choseYourClasseScreenScreenState();
}

class _choseYourClasseScreenScreenState extends State<choseYourClasseScreen> {
  int _selectedMascotIndex = 0;
  @override
  void initState() {
    super.initState();
    if (widget.draft == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Please enter class details first.'))),
        );
        Navigator.pop(context);
      });
    }
  }

  void _goToAddStudents() {
    final draft = widget.draft;
    if (draft == null) return;

    Navigator.pushNamed(
      context,
      AppRouter.addstudentsclass,
      arguments: draft.copyWith(
        mascotCode: ClassCreationDraft.mascotCodeAtIndex(_selectedMascotIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(50, 10, 50, 14),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _goToAddStudents,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43C2BD),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(context.tr('NEXT'),
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1C1C),
                  letterSpacing: .6,
                ),
              ),
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF47495),
                      ),
                      child: const Icon(Icons.arrow_back, size: 18, color: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(context.tr('Step 2 of 3'),
                          style: textTheme.labelMedium?.copyWith(
                            color: const Color(0xFFF47495),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 6),
                        SizedBox(
                          width: 140,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF47495),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF47495),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: 34),
                ],
              ),
              SizedBox(height: 18),
              Text(context.tr('Choose your Class Mascot'),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1C1C),
                ),
              ),
              SizedBox(height: 8),
              Text(context.tr('This little friend will guide your students through their reading\njourney, celebrating victories and offering hints along the way.'),
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF717786),
                  height: 1.25,
                ),
              ),
              SizedBox(height: 16),
              _mascotOptionCard(
                context,
                index: 0,
                title: context.tr('Alphabet Lounge'),
                description: context.tr('Master the letter sounds using songs,\ntactile games, and quick wins.'),
                image: AppAssets.exploreimage,
              ),
              SizedBox(height: 14),
              _mascotOptionCard(
                context,
                index: 1,
                title: context.tr('Blend Forest'),
                description: context.tr("Deep in the woods, letters love to join\nhands. Let's find the sounds they make\ntogether!"),
                image: AppAssets.journeyimage,
              ),
              SizedBox(height: 14),
              _mascotOptionCard(
                context,
                index: 2,
                title: context.tr('Vowel Learning'),
                description: context.tr("Master the building blocks of every word.\nExplore how tiny shifts in sound transform\n'cap' into 'cape'."),
                image: AppAssets.vowelsimage,
              ),
              SizedBox(height: 14),
              _mascotOptionCard(
                context,
                index: 3,
                title: context.tr('Phonics Cards'),
                description: context.tr('Flip, match, and master phonics patterns\nwith playful card challenges.'),
                image: AppAssets.phonicsimage,
              ),
              SizedBox(height: 14),
              _mascotOptionCard(
                context,
                index: 4,
                title: context.tr('Interactive Smart Chart'),
                description: context.tr('Explore the sounds of PhonoQuest. Tap\nany tile to hear the phoneme and see its\nmagic pattern.'),
                image: AppAssets.smartchartimage,
              ),
              SizedBox(height: 14),
              _mascotOptionCard(
                context,
                index: 5,
                title: context.tr('Practice Mode'),
                description: context.tr('Build confidence with quick drills and\nrepeatable phonics practice sessions.'),
                image: AppAssets.practiceimage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mascotOptionCard(
    BuildContext context, {
    required int index,
    required String title,
    required String description,
    required String image,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final bool selected = _selectedMascotIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedMascotIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF3F8FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF0B57D0) : const Color(0xFFE5E7EB),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? const Color(0xFF0B57D0) : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                    color: selected ? const Color(0xFF0B57D0) : Colors.transparent,
                  ),
                  child: selected
                      ? Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                        )
                      : null,
                ),
              ],
            ),
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF3F5F7),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                image,
                width: 54,
                height: 54,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1A1C1C),
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: const Color(0xFF717786),
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
