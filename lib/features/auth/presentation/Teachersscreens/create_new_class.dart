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

class createNewClasseScreen extends StatefulWidget {
  const createNewClasseScreen({super.key});

  @override
  State<createNewClasseScreen> createState() => _createNewClasseScreenState();
}

class _createNewClasseScreenState extends State<createNewClasseScreen> {
  final _classNameController = TextEditingController();
  String _selectedGrade = 'Grade 1';

  @override
  void dispose() {
    _classNameController.dispose();
    super.dispose();
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
              onPressed: () {
                final name = _classNameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('Please enter a class name.'))),
                  );
                  return;
                }
                Navigator.pushNamed(
                  context,
                  AppRouter.choseyourclass,
                  arguments: ClassCreationDraft(
                    name: name,
                    gradeLevel: ClassCreationDraft.gradeLevelFromUi(_selectedGrade),
                    mascotCode: ClassCreationDraft.mascotCodes.first,
                  ),
                );
              },
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
                        Text(context.tr('Step 1 of 3'),
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
                                    color: const Color(0xFFE5E7EB),
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
              Text(context.tr('Create New Class'),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1C1C),
                ),
              ),
              SizedBox(height: 8),
              Text(context.tr("Let's set up a new space for your readers. Start by giving your\nclass an identity."),
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF717786),
                  height: 1.25,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('Class Name'),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1C1C),
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _classNameController,
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: context.tr('e.g., Morning Owls'),
                                hintStyle: textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF717786),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Icon(Icons.edit, size: 18, color: const Color(0xFF717786)),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(context.tr('Choose a fun, recognizable name for your students.'),
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF717786),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('Grade Level'),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1C1C),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _gradeChip(context, label: context.tr('Pre-K'))),
                        SizedBox(width: 12),
                        Expanded(child: _gradeChip(context, label: context.tr('Grade 1'))),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _gradeChip(context, label: context.tr('Grade 2'))),
                        SizedBox(width: 12),
                        Expanded(child: _gradeChip(context, label: context.tr('Grade 3+'))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gradeChip(BuildContext context, {required String label}) {
    final textTheme = Theme.of(context).textTheme;
    final bool selected = _selectedGrade == label;

    return InkWell(
      onTap: () => setState(() => _selectedGrade = label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFDDEBFF) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF0B57D0) : Colors.transparent),
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: selected ? const Color(0xFF0B57D0) : const Color(0xFF3B3F45),
          ),
        ),
      ),
    );
  }
}
