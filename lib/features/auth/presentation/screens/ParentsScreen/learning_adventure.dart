// ignore_for_file: prefer_const_constructors, camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../core/network/api_exception.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../shared/constants/app_assets.dart';
import '../../../../../shared/widgets/phono_back_button.dart';
import '../../../../../shared/widgets/phono_shell.dart';
import '../../../../../shared/widgets/primary_button.dart';
import '../../../../subscription/data/subscription_models.dart';
import '../../../../subscription/data/subscription_repository.dart';
import '../../../data/auth_repository.dart';
import '../../../domain/parent_registration_draft.dart';
import '../../../../../core/l10n/app_language_controller.dart';

class LearningAdventureScreen extends StatefulWidget {
  const LearningAdventureScreen({super.key, this.draft});

  final ParentRegistrationDraft? draft;

  @override
  State<LearningAdventureScreen> createState() => _LearningAdventureScreenState();
}

class _LearningAdventureScreenState extends State<LearningAdventureScreen> {
  final _repo = SubscriptionRepository();
  String _selectedPlan = 'basic';
  bool _submitting = false;
  bool _loadingPlans = true;
  List<SubscriptionPlanCatalogItem> _plans = const [];

  @override
  void initState() {
    super.initState();
    if (widget.draft == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Please complete the previous steps first.'))),
        );
        Navigator.pop(context);
      });
    } else {
      _loadPlans();
    }
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await _repo.fetchPublicPlans();
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _loadingPlans = false;
        if (plans.isNotEmpty && !plans.any((p) => p.code == 'basic')) {
          _selectedPlan = plans.firstWhere((p) => p.price <= 0, orElse: () => plans.first).code;
        } else {
          _selectedPlan = 'basic';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _plans = _fallbackPlans();
        _loadingPlans = false;
      });
    }
  }

  List<SubscriptionPlanCatalogItem> _fallbackPlans() {
    return const [
      SubscriptionPlanCatalogItem(
        id: 1,
        name: 'Basic',
        code: 'basic',
        billingCycle: 'monthly',
        price: 0,
        currency: 'USD',
        trialDays: 0,
        isActive: true,
        priceLabel: 'Free',
        billingSuffix: '/forever',
        description: 'A perfect starting point to explore foundational phonics.',
        features: [
          'Basic phonics access',
          'Alphabet lessons',
          'Limited practice tools',
          'Public homepage access',
        ],
        lockedFeatures: [
          'Full phonics library',
          'Word Builder access',
          'Progress dashboard',
          'Rewards and advanced practice',
        ],
      ),
      SubscriptionPlanCatalogItem(
        id: 2,
        name: 'Intermediate',
        code: 'intermediate',
        billingCycle: 'monthly',
        price: 9.99,
        currency: 'USD',
        trialDays: 0,
        isActive: true,
        priceLabel: '\$9.99',
        billingSuffix: '/mo',
        description: 'Flexible full access on a month-to-month basis.',
        features: [
          'Full phonics library',
          'Word Builder access',
          'Progress dashboard',
          'Rewards and advanced practice',
        ],
        lockedFeatures: [
          'All Advance-tier adventures',
          'Long-term learning access',
          'Best value yearly pricing',
        ],
      ),
      SubscriptionPlanCatalogItem(
        id: 3,
        name: 'Advance',
        code: 'advance',
        billingCycle: 'yearly',
        price: 99,
        currency: 'USD',
        trialDays: 0,
        isActive: true,
        priceLabel: '\$99',
        billingSuffix: '/yr',
        badge: 'BEST VALUE',
        saveText: 'Best value for families and teachers',
        description: 'Everything in Intermediate with the best yearly value.',
        features: [
          'Everything in Intermediate',
          'Best value pricing',
          'Long-term learning access',
          'Ideal for families and teachers',
        ],
        lockedFeatures: [],
      ),
    ];
  }

  String _buttonLabelFor(SubscriptionPlanCatalogItem plan) {
    if (plan.code == 'basic') return 'Start Free';
    return 'Select Plan';
  }

  bool _isSignupSelectablePlan(SubscriptionPlanCatalogItem plan) {
    return plan.code == 'basic' || plan.price <= 0;
  }

  void _onPlanTap(SubscriptionPlanCatalogItem plan) {
    if (!_isSignupSelectablePlan(plan)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('Start with Basic for free. Upgrade anytime in Settings after signup.'),
          ),
        ),
      );
      return;
    }
    setState(() => _selectedPlan = plan.code);
  }

  Future<void> _submit() async {
    final base = widget.draft;
    if (base == null || _submitting) return;

    final draft = base.copyWith(subscriptionPlanCode: 'basic');

    setState(() => _submitting = true);
    try {
      await AuthRepository().registerParent(draft);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.parentssetupcomplete);
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
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0DF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(context.tr('STEP 4 OF 4'),
                          style: TextStyle(
                            color: Color(0xFFF87792),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .5,
                          ),
                        ),
                      ),
                      SizedBox(height: 14),
                      Text(context.tr('Choose Your Learning\nAdventure'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(context.tr('Your family starts on the free Basic plan.\nPaid plans unlock later in Settings.'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.25,
                          color: Colors.black.withOpacity(.55),
                        ),
                      ),
                      SizedBox(height: 18),
                      Expanded(
                        child: _loadingPlans
                            ? Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Column(
                                  children: [
                                    for (var i = 0; i < _plans.length; i++) ...[
                                      if (i > 0) SizedBox(height: 12),
                                      _PlanCard(
                                        title: _plans[i].name,
                                        price: _plans[i].priceLabel,
                                        suffix: _plans[i].billingSuffix,
                                        badge: _plans[i].badge,
                                        saveText: _plans[i].saveText,
                                        description: _plans[i].description,
                                        buttonText: _isSignupSelectablePlan(_plans[i])
                                            ? _buttonLabelFor(_plans[i])
                                            : context.tr('Upgrade in Settings'),
                                        isSelected: _selectedPlan == _plans[i].code,
                                        isSignupLocked: !_isSignupSelectablePlan(_plans[i]),
                                        features: _plans[i].features,
                                        disabledFeatures: _plans[i].lockedFeatures,
                                        onSelect: () => _onPlanTap(_plans[i]),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                      ),
                      PrimaryButton(
                        label: _submitting ? 'SUBMITTING...' : 'NEXT',
                        onTap: _submitting || _loadingPlans ? () {} : _submit,
                      ),
                      SizedBox(height: 14),
                      Center(
                        child: PhonoBackButton(onTap: () => Navigator.pop(context)),
                      ),
                      SizedBox(height: 16),
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

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String suffix;
  final String? badge;
  final String? saveText;
  final String description;
  final String buttonText;
  final bool isSelected;
  final bool isSignupLocked;
  final List<String> features;
  final List<String> disabledFeatures;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.suffix,
    required this.description,
    required this.buttonText,
    required this.isSelected,
    this.isSignupLocked = false,
    required this.features,
    required this.onSelect,
    this.badge,
    this.saveText,
    this.disabledFeatures = const [],
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isSignupLocked
        ? const Color(0xFFD0D5DD)
        : (isSelected ? const Color(0xFF49D3CF) : const Color(0xFFFF6F98));

    return Opacity(
      opacity: isSignupLocked ? 0.72 : 1,
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: isSignupLocked
            ? const Color(0xFFF9FAFB)
            : (isSelected ? const Color(0xFFEDEDED) : Colors.white),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.3),
      ),
      child: Stack(
        children: [
          if (isSignupLocked)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 10, color: Colors.black54),
                    SizedBox(width: 4),
                    Text(
                      'After signup',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (badge != null && !isSignupLocked)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD54F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? const Color(0xFF168AA4) : Colors.black,
                ),
              ),
              SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: .9,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 3),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      suffix,
                      style: const TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ),
                ],
              ),
              if (saveText != null) ...[
                SizedBox(height: 4),
                Text(
                  saveText!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF21A8C9),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              SizedBox(height: 14),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  color: Colors.black.withOpacity(.62),
                ),
              ),
              SizedBox(height: 14),
              ...features.map((item) => _FeatureRow(text: item, enabled: true)),
              ...disabledFeatures.map((item) => _FeatureRow(text: item, enabled: false)),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: onSelect,
                  style: TextButton.styleFrom(
                    backgroundColor: isSignupLocked
                        ? const Color(0xFFE5E7EB)
                        : (isSelected ? const Color(0xFFFF6F98) : const Color(0xFFE6E6E6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      color: isSignupLocked
                          ? Colors.black54
                          : (isSelected ? Colors.white : Colors.black),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  final bool enabled;

  const _FeatureRow({
    required this.text,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.close,
            size: 13,
            color: enabled ? const Color(0xFF4CAF50) : Colors.black26,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10.8,
                height: 1.25,
                color: enabled ? Colors.black87 : Colors.black38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
