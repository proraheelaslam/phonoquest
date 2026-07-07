// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/standard_screen_header.dart';
import '../../../auth/presentation/screens/ParentsScreen/parent_link_child_helper.dart';
import '../../data/subscription_models.dart';
import '../../data/subscription_repository.dart';
import '../../../../core/l10n/app_language_controller.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() => _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState extends State<SubscriptionManagementScreen> {
  final _repo = SubscriptionRepository();

  SubscriptionMe? _me;
  List<SubscriptionPlanCatalogItem> _plans = const [];
  String? _selectedPlanCode;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    if (forceRefresh) ApiClient.clearRequestCache();
    setState(() => _loading = true);
    try {
      final me = await _repo.fetchMe();
      List<SubscriptionPlanCatalogItem> plans = const [];
      if (me.canManage) {
        plans = await _repo.fetchPlans();
      }
      if (!mounted) return;
      setState(() {
        _me = me;
        _plans = plans;
        _selectedPlanCode = me.currentPlanCode;
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

  Future<void> _savePlan() async {
    final me = _me;
    final code = _selectedPlanCode;
    if (me == null || !me.canManage || code == null || _saving) return;
    if (code == me.currentPlanCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('This plan is already active.'))),
      );
      return;
    }

    final selectedPlan =
        _plans.where((p) => p.code == code).firstOrNull;
    if (selectedPlan != null && selectedPlan.price > 0) {
      final paid = await Navigator.pushNamed(context, AppRouter.payment, arguments: code);
      if (!mounted) return;
      if (paid == true) {
        await _load(forceRefresh: true);
      }
      return;
    }

    final selectedName = selectedPlan?.name ?? code.replaceAll('_', ' ');
    final isStudentSelf = me.role == 'student' && me.planManagedBy == 'self';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr(isStudentSelf ? 'Change your plan?' : 'Change family plan?')),
        content: Text(
          isStudentSelf
              ? 'Switch to $selectedName? This updates your reading paces and module access.'
              : 'Switch to $selectedName? This updates printable access and family benefits for your linked child.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.tr('Cancel'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.tr('Confirm'))),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      final updated = await _repo.changePlan(code);
      if (!mounted) return;
      ApiClient.clearRequestCache();
      setState(() {
        _me = updated;
        _selectedPlanCode = updated.currentPlanCode;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              isStudentSelf ? 'Your plan was updated successfully.' : 'Family plan updated successfully.',
            ),
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _buttonLabelFor(SubscriptionPlanCatalogItem plan) {
    if (plan.code == _me?.currentPlanCode) return 'Current Plan';
    if (plan.code == 'basic') return 'Start Free';
    if (plan.code == 'intermediate') return 'Get Started';
    if (plan.code == 'advance') return 'Choose Advance';
    if (plan.billingCycle == 'yearly') return 'Choose Yearly';
    return 'Select Monthly';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final me = _me;

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      wrapInScrollView: false,
      child: _loading
          ? Center(child: CircularProgressIndicator())
          : me == null
              ? Center(child: Text(context.tr('Could not load subscription.')))
              : RefreshIndicator(
                  onRefresh: () => _load(forceRefresh: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppScaffold.pageScrollPadding(context, top: 7, horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StandardScreenHeader(title: context.tr('Subscription')),
                        SizedBox(height: 14),
                        _currentPlanCard(me),
                        if (me.paymentRequired && me.pendingCheckoutPlanCode != null) ...[
                          SizedBox(height: 12),
                          _pendingPaymentBanner(me),
                        ],
                        if (me.message != null && me.message!.isNotEmpty) ...[
                          SizedBox(height: 12),
                          _infoBanner(me.message!),
                        ],
                        if (me.role == 'parent' && me.canManage && me.childLinked != true) ...[
                          SizedBox(height: 12),
                          _linkChildBanner(),
                        ],
                        if (me.canManage) ...[
                          SizedBox(height: 12),
                          Text(
                            context.tr(
                              me.role == 'student' ? 'Your plan includes' : 'Your plan includes',
                            ),
                            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 8),
                          ...me.features.map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: _featureRow(f, enabled: true),
                            ),
                          ),
                          SizedBox(height: 18),
                          SizedBox(height: 18),
                          Text(
                            context.tr(
                              me.role == 'student' && me.planManagedBy == 'self'
                                  ? 'Choose a Plan'
                                  : 'Choose a Family Plan',
                            ),
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1C1C),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            context.tr(
                              me.role == 'student' && me.planManagedBy == 'self'
                                  ? 'Paid plans open secure checkout. Upgrade to unlock more reading paces.'
                                  : 'Paid plans open secure checkout. Free plans update instantly.',
                            ),
                            style: textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
                          ),
                          SizedBox(height: 14),
                          ..._plans.map((plan) {
                            final selected = _selectedPlanCode == plan.code;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _SubscriptionPlanCard(
                                title: plan.name,
                                price: plan.priceLabel,
                                suffix: plan.billingSuffix,
                                badge: plan.badge,
                                saveText: plan.saveText,
                                description: plan.description,
                                buttonText: _buttonLabelFor(plan),
                                isSelected: selected,
                                features: plan.features,
                                disabledFeatures: plan.lockedFeatures,
                                onSelect: () => setState(() => _selectedPlanCode = plan.code),
                              ),
                            );
                          }),
                          SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saving ? null : _savePlan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF53C8C1),
                                foregroundColor: const Color(0xFF1A1C1C),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _saving
                                    ? 'SAVING...'
                                    : (_selectedPlanCode != null &&
                                            (_plans
                                                    .where((p) => p.code == _selectedPlanCode)
                                                    .firstOrNull
                                                    ?.price ??
                                                0) >
                                                0
                                        ? 'CONTINUE TO PAYMENT'
                                        : 'SAVE PLAN CHANGES'),
                                style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: .4),
                              ),
                            ),
                          ),
                        ] else ...[
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, AppRouter.studentPace),
                              icon: const Icon(Icons.speed_rounded, size: 18),
                              label: Text(context.tr('CHANGE READING PACE')),
                            ),
                          ),
                          SizedBox(height: 18),
                          Text(context.tr('Your Access'),
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1C1C),
                            ),
                          ),
                          SizedBox(height: 10),
                          ...me.features.map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _featureRow(f, enabled: true),
                            ),
                          ),
                          ...me.lockedFeatures.map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _featureRow(f, enabled: false),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _currentPlanCard(SubscriptionMe me) {
    final gradient = me.isPremium
        ? const [Color(0xFF19B6D2), Color(0xFF25A9B1)]
        : const [Color(0xFF7DD3FC), Color(0xFF38BDF8)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                me.isPremium ? Icons.diamond_rounded : Icons.star_rounded,
                color: me.isPremium ? Colors.pinkAccent : Colors.white,
                size: 36,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      me.currentPlanName,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if (me.priceLabel != null && me.priceLabel!.isNotEmpty)
                      Text(
                        me.priceLabel!,
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: Colors.white.withOpacity(.92),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              if (me.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(context.tr('PREMIUM'),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          if (me.familyPlanLabel != null) ...[
            SizedBox(height: 10),
            Text(
              me.familyPlanLabel!,
              style: GoogleFonts.lexend(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
          if (me.managedByLabel != null) ...[
            SizedBox(height: 6),
            Text(
              me.managedByLabel!,
              style: GoogleFonts.lexend(fontSize: 11, color: Colors.white.withOpacity(.9)),
            ),
          ],
          if (me.role == 'parent' && me.linkedChildName != null && me.canManage) ...[
            SizedBox(height: 6),
            Text(
              'Covers ${me.linkedChildName}',
              style: GoogleFonts.lexend(fontSize: 11, color: Colors.white.withOpacity(.9)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pendingPaymentBanner(SubscriptionMe me) {
    final planName = me.pendingCheckoutPlanName ?? me.pendingCheckoutPlanCode ?? 'Premium';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF47495)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('Complete payment for $planName'),
            style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final code = me.pendingCheckoutPlanCode;
                if (code == null) return;
                final paid = await Navigator.pushNamed(context, AppRouter.payment, arguments: code);
                if (!mounted) return;
                if (paid == true) await _load(forceRefresh: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF47495),
                foregroundColor: Colors.black,
              ),
              child: Text(context.tr('COMPLETE PAYMENT')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linkChildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0DF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD7A8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('Link your child to activate the family plan'),
            style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text(context.tr('Your subscription applies once your child account is linked.'),
            style: GoogleFonts.lexend(fontSize: 11, height: 1.35),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                final linked = await openParentLinkChildAccount(context);
                if (linked == true && mounted) await _load();
              },
              child: Text(context.tr('LINK CHILD ACCOUNT')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBanner(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFE08A)),
      ),
      child: Text(
        text,
        style: GoogleFonts.lexend(fontSize: 11.5, height: 1.4, color: const Color(0xFF5C4A1F)),
      ),
    );
  }

  Widget _featureRow(String text, {required bool enabled}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          enabled ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
          size: 16,
          color: enabled ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.lexend(
              fontSize: 12,
              height: 1.35,
              color: enabled ? const Color(0xFF1A1C1C) : const Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubscriptionPlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String suffix;
  final String? badge;
  final String? saveText;
  final String description;
  final String buttonText;
  final bool isSelected;
  final List<String> features;
  final List<String> disabledFeatures;
  final VoidCallback onSelect;

  const _SubscriptionPlanCard({
    required this.title,
    required this.price,
    required this.suffix,
    required this.description,
    required this.buttonText,
    required this.isSelected,
    required this.features,
    required this.onSelect,
    this.badge,
    this.saveText,
    this.disabledFeatures = const [],
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? const Color(0xFF49D3CF) : const Color(0xFFFF6F98);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEDEDED) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.3),
      ),
      child: Stack(
        children: [
          if (badge != null)
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
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.black),
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
                    child: Text(suffix, style: const TextStyle(fontSize: 10, color: Colors.black)),
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
                style: TextStyle(fontSize: 11.5, height: 1.35, color: Colors.black.withOpacity(.62)),
              ),
              SizedBox(height: 14),
              ...features.map((item) => _PlanFeatureRow(text: item, enabled: true)),
              ...disabledFeatures.map((item) => _PlanFeatureRow(text: item, enabled: false)),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: onSelect,
                  style: TextButton.styleFrom(
                    backgroundColor: isSelected ? const Color(0xFFFF6F98) : const Color(0xFFE6E6E6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
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
    );
  }
}

class _PlanFeatureRow extends StatelessWidget {
  final String text;
  final bool enabled;

  const _PlanFeatureRow({required this.text, required this.enabled});

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
