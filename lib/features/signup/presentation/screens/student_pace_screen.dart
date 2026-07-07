import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/standard_screen_header.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../settings/data/models/learner_profile.dart';
import '../../../settings/data/repositories/profile_repository.dart';
import '../../../subscription/data/student_access_models.dart';
import '../../../subscription/data/subscription_repository.dart';
import '../widgets/pace_card.dart';
import '../../../../core/l10n/app_language_controller.dart';

class StudentPaceScreen extends StatefulWidget {
  const StudentPaceScreen({super.key});

  @override
  State<StudentPaceScreen> createState() => _StudentPaceScreenState();
}

class _StudentPaceScreenState extends State<StudentPaceScreen> {
  final _accessRepo = SubscriptionRepository();
  final _profileRepo = ProfileRepository(apiClient: ApiClient());

  StudentAccess? _access;
  int _selected = 0;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final access = await _accessRepo.fetchStudentAccess();
      if (!mounted) return;
      setState(() {
        _access = access;
        _selected = paceIndexFromCode(access.currentReadingLevel);
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
    }
  }

  void _onPaceTap(int index) {
    final access = _access;
    if (access == null || index >= access.paceOptions.length) return;
    final option = access.paceOptions[index];
    if (option.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(option.lockReason ?? 'This pace requires a family plan upgrade.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }
    setState(() => _selected = index);
  }

  Future<void> _save() async {
    final access = _access;
    if (access == null || _saving) return;

    final option = access.paceOptions[_selected];
    if (option.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(option.lockReason ?? 'This pace is not included in your family plan.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return;
    }
    if (option.code == access.currentReadingLevel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('This pace is already active.'))),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _profileRepo.updateProfile(
        ProfileUpdateRequest(readingLevel: readingLevelFromPaceIndex(_selected)),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${option.title} pace activated — new adventures unlocked!')),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final access = _access;
    final selectedOption = access != null && access.paceOptions.length > _selected
        ? access.paceOptions[_selected]
        : null;

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      wrapInScrollView: false,
      child: _loading
          ? Center(child: CircularProgressIndicator())
          : access == null
              ? Center(child: Text(context.tr('Could not load pace options.')))
              : SingleChildScrollView(
                  padding: AppScaffold.pageScrollPadding(context, top: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StandardScreenHeader(title: context.tr('Choose your pace')),
                      SizedBox(height: 8),
                      Text(
                        access.planManagedBy == 'parent'
                            ? 'Family plan: ${access.planName}'
                            : 'Your plan: ${access.planName}',
                        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Current pace: ${access.paceLabel}',
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (access.paceSummary != null) ...[
                        SizedBox(height: 4),
                        Text(access.paceSummary!, style: textTheme.bodySmall),
                      ],
                      if (access.upgradeMessage != null) ...[
                        SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(access.upgradeMessage!, style: const TextStyle(fontSize: 11.5, height: 1.35)),
                        ),
                      ],
                      SizedBox(height: 16),
                      for (var i = 0; i < access.paceOptions.length; i++) ...[
                        if (i > 0) SizedBox(height: 12),
                        PaceCard(
                          title: access.paceOptions[i].title,
                          subtitle: access.paceOptions[i].subtitle,
                          level: access.paceOptions[i].levelLabel,
                          selected: _selected == i,
                          locked: access.paceOptions[i].isLocked,
                          summary: access.paceOptions[i].summary,
                          features: access.paceOptions[i].features,
                          onTap: () => _onPaceTap(i),
                          selectedImageAsset: AppAssets.begineerimage,
                          unselectedImageAsset: AppAssets.advanceimage,
                        ),
                      ],
                      if (selectedOption != null && selectedOption.lockedFeatures.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Text('${context.tr('Not included at ')}${selectedOption.title}', style: textTheme.labelMedium),
                        SizedBox(height: 6),
                        ...selectedOption.lockedFeatures.map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.lock_outline, size: 14, color: Color(0xFF9CA3AF)),
                                SizedBox(width: 6),
                                Expanded(child: Text(f, style: textTheme.bodySmall)),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (!access.isPremium && access.canUpgrade) ...[
                        SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.pushNamed(context, AppRouter.subscription),
                          child: Text(
                            context.tr(
                              access.planManagedBy == 'parent'
                                  ? 'VIEW FAMILY PLAN'
                                  : 'UPGRADE PLAN',
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 24),
                      PrimaryButton(
                        label: _saving ? 'SAVING...' : 'SAVE PACE',
                        onTap: _saving ? () {} : _save,
                      ),
                    ],
                  ),
                ),
    );
  }
}
