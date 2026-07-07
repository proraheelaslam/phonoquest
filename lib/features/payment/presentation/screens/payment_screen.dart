// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/auth/current_user_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/auth_navigation.dart';
import '../../../../shared/constants/app_assets.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/standard_screen_header.dart';
import '../../../subscription/data/subscription_models.dart';
import '../../../subscription/data/subscription_repository.dart';
import '../../../../core/l10n/app_language_controller.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.planCode});

  final String planCode;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _repo = SubscriptionRepository();
  SubscriptionPlanCatalogItem? _plan;
  bool _loading = true;
  bool _paying = false;
  SubscriptionCheckoutResult? _receipt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final plans = await _repo.fetchPlans();
      final plan = plans.where((p) => p.code == widget.planCode).firstOrNull;
      if (!mounted) return;
      setState(() {
        _plan = plan;
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

  Future<String> _resolveRole() async {
    final local = await CurrentUserStorage.instance.readProfile();
    if (local != null && local.roleName.isNotEmpty) {
      return local.roleName;
    }
    try {
      final me = await _repo.fetchMe();
      return me.role;
    } catch (_) {
      return 'student';
    }
  }

  Future<void> _goToRoleDashboard() async {
    ApiClient.clearRequestCache();
    final role = await _resolveRole();
    if (!mounted) return;
    final route = dashboardRouteForRole(role);
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
  }

  Future<void> _completePayment() async {
    if (_paying) return;
    setState(() => _paying = true);
    try {
      ApiClient.clearRequestCache();
      final receipt = await _repo.checkout(widget.planCode);
      if (!mounted) return;
      setState(() {
        _receipt = receipt;
        _paying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(receipt.message),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      await _goToRoleDashboard();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _paying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final plan = _plan;
    final receipt = _receipt;

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      wrapInScrollView: false,
      child: _loading
          ? Center(child: CircularProgressIndicator())
          : plan == null
              ? Center(child: Text(context.tr('Could not load plan details.')))
              : SingleChildScrollView(
                  padding: AppScaffold.pageScrollPadding(context, top: 7, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StandardScreenHeader(title: context.tr('Payment')),
                      SizedBox(height: 14),
                      _planSummary(plan),
                      SizedBox(height: 14),
                      _paymentMethodCard(textTheme),
                      SizedBox(height: 14),
                      _orderSummary(plan, textTheme),
                      if (receipt != null) ...[
                        SizedBox(height: 14),
                        _receiptCard(receipt, textTheme),
                      ],
                      SizedBox(height: 20),
                      if (receipt == null)
                        PrimaryButton(
                          label: context.tr('COMPLETE PAYMENT'),
                          isBusy: _paying,
                          onTap: _completePayment,
                        )
                      else
                        PrimaryButton(
                          label: context.tr('CONTINUE'),
                          onTap: _goToRoleDashboard,
                        ),
                      SizedBox(height: 8),
                      Text(context.tr('Demo checkout — your family plan is activated immediately after payment.'),
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6B7280),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _planSummary(SubscriptionPlanCatalogItem plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF19B6D2), Color(0xFF25A9B1)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.name,
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${plan.priceLabel}${plan.billingSuffix}',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(.92),
            ),
          ),
          SizedBox(height: 8),
          Text(
            plan.description,
            style: GoogleFonts.lexend(
              fontSize: 11,
              color: Colors.white.withOpacity(.9),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodCard(TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFBFF3ED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.credit_card_rounded, color: Color(0xFF1A1C1C)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('Demo Card'),
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(context.tr('**** **** **** 4242'),
                  style: textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Text(
            'Default',
            style: textTheme.labelSmall?.copyWith(
              color: const Color(0xFF53C8C1),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderSummary(SubscriptionPlanCatalogItem plan, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 191, 0, 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _summaryRow('Plan', plan.name, textTheme),
          SizedBox(height: 8),
          _summaryRow('Billing', plan.billingCycle, textTheme),
          const Divider(height: 20),
          _summaryRow(
            'Total due today',
            '${plan.priceLabel}${plan.billingSuffix}',
            textTheme,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, TextTheme textTheme, {bool bold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            color: bold ? const Color(0xFF8C6A1A) : null,
          ),
        ),
      ],
    );
  }

  Widget _receiptCard(SubscriptionCheckoutResult receipt, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(83, 200, 193, 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF53C8C1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF53C8C1)),
              SizedBox(width: 8),
              Text(context.tr('Payment successful'),
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('Transaction: ${receipt.transactionId}', style: textTheme.bodySmall),
          Text(receipt.message, style: textTheme.bodySmall?.copyWith(height: 1.35)),
        ],
      ),
    );
  }
}
