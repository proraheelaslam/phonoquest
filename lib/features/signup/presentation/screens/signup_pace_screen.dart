import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/auth_flow_navigation.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/phono_back_button.dart';
import '../../../../shared/widgets/phono_shell.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../subscription/data/student_access_models.dart';
import '../../domain/student_registration_draft.dart';
import '../widgets/pace_card.dart';
import '../../../../core/l10n/app_language_controller.dart';

class SignupPaceScreen extends StatefulWidget {
  const SignupPaceScreen({super.key, this.draft});

  final StudentRegistrationDraft? draft;

  @override
  State<SignupPaceScreen> createState() => _SignupPaceScreenState();
}

class _SignupPaceScreenState extends State<SignupPaceScreen> {
  int selected = 0;
  bool _submitting = false;
  final _access = StudentAccess.signupDefaults();

  @override
  void initState() {
    super.initState();
    if (widget.draft == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Please complete your details first.'))),
        );
        Navigator.pop(context);
      });
    }
  }

  void _onPaceTap(int index) {
    final option = _access.paceOptions[index];
    if (option.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            option.lockReason ??
                context.tr('Unlock this pace later with a subscription plan in Settings.'),
          ),
        ),
      );
      return;
    }
    setState(() => selected = index);
  }

  Future<void> _finishSetup() async {
    final draft = widget.draft;
    if (draft == null || _submitting) return;

    setState(() => _submitting = true);
    final names = draft.splitName();
    const readingLevel = 'beginner';

    try {
      final session = await AuthRepository().registerStudent(
        firstName: names.firstName,
        lastName: names.lastName,
        email: draft.email,
        password: draft.password,
        readingLevel: readingLevel,
      );
      if (!mounted) return;
      ApiClient.clearRequestCache();
      if (session.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Welcome! Your Beginner journey is ready.')),
          ),
        );
      }
      navigateAfterAuth(context, session);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Something went wrong. Please try again.')), backgroundColor: Colors.red.shade800),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = _access.paceOptions;

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
              child: SvgPicture.asset(AppAssets.signUpBackground, fit: BoxFit.cover),
            ),
            SafeArea(
              child: PhonoShell(
                stepLabel: '',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 50, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(context.tr('Choose your pace'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(context.tr('Each pace unlocks different learning adventures. You can change this anytime in settings.'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      if (_access.upgradeMessage != null) ...[
                        SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _access.upgradeMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11.5, height: 1.35),
                          ),
                        ),
                      ],
                      SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              for (var i = 0; i < options.length; i++) ...[
                                if (i > 0) SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: PaceCard(
                                    title: options[i].title,
                                    subtitle: options[i].subtitle,
                                    level: options[i].levelLabel,
                                    selected: selected == i,
                                    locked: options[i].isLocked,
                                    summary: options[i].summary,
                                    features: options[i].features,
                                    onTap: () => _onPaceTap(i),
                                    selectedImageAsset: AppAssets.begineerimage,
                                    unselectedImageAsset: AppAssets.advanceimage,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      PrimaryButton(
                        label: context.tr('FINISH SETUP'),
                        onTap: _finishSetup,
                        isBusy: _submitting,
                      ),
                      SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: PhonoBackButton(onTap: () => Navigator.pop(context)),
                      ),
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
