// ignore_for_file: deprecated_member_use, prefer_const_constructors, sized_box_for_whitespace, camel_case_types

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/core/router/app_router.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/teacher_assignment_models.dart';
import '../../data/teacher_assignment_repository.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import 'module_ui_helper.dart';
import '../../../../core/l10n/app_language_controller.dart';

class reviewAssignmentScreen extends StatefulWidget {
  const reviewAssignmentScreen({super.key});

  @override
  State<reviewAssignmentScreen> createState() => _reviewAssignmentScreenState();
}

class _reviewAssignmentScreenState extends State<reviewAssignmentScreen> {
  final _repo = TeacherAssignmentRepository();

  List<ReviewQueueItem> _items = const [];
  bool _loading = true;

  static const _tagPalettes = [
    (Color(0xFFDBEAFE), Color(0xFF1D4ED8)),
    (Color(0xFFFFF1C2), Color(0xFF8A5A00)),
    (Color(0xFFD1FAE5), Color(0xFF10B981)),
    (Color(0xFFFFE4E6), Color(0xFFBE123C)),
    (Color(0xFFE0E7FF), Color(0xFF4338CA)),
  ];

  @override
  void initState() {
    super.initState();
    _loadQueue();
  }

  Future<void> _loadQueue() async {
    setState(() => _loading = true);
    try {
      final items = await _repo.fetchReviewQueue(limit: 50);
      if (!mounted) return;
      setState(() {
        _items = items;
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

  (Color, Color) _tagColors(int index) {
    final palette = _tagPalettes[index % _tagPalettes.length];
    return palette;
  }

  void _openAssignmentDetail(ReviewQueueItem item) {
    Navigator.pushNamed(
      context,
      AppRouter.assignmentdetail,
      arguments: item.assignmentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final pendingLabel = _items.isEmpty
        ? 'No submissions to review'
        : '${_items.length} pending review';

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      child: _loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadQueue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: SizedBox(
                        height: 58,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(context.tr('Review Assignments'),
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1A1C1C),
                                  ),
                                ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _items.isEmpty
                                          ? const Color(0xFF9CA3AF)
                                          : const Color(0xFFFCC419),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    pendingLabel,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF717786),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
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
                          ),
                        ],
                      ),
                    ),
                    ),
                    SizedBox(height: 16),
                    if (_items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF9CA3AF)),
                              SizedBox(height: 12),
                              Text(context.tr('No student submissions yet'),
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4B5563),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(context.tr('When students complete assigned modules,\nthey will appear here for review.'),
                                textAlign: TextAlign.center,
                                style: textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    for (var i = 0; i < _items.length; i++) ...[
                      _assignmentCard(
                        context,
                        item: _items[i],
                        tagBg: _tagColors(i).$1,
                        tagFg: _tagColors(i).$2,
                        onReview: () => _openAssignmentDetail(_items[i]),
                      ),
                      if (i < _items.length - 1) SizedBox(height: 12),
                    ],
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _assignmentCard(
    BuildContext context, {
    required ReviewQueueItem item,
    required Color tagBg,
    required Color tagFg,
    required VoidCallback onReview,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final initials = ModuleUiHelper.initialsFor(item.displayName);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F3F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1C1C),
                      ),
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.tagLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: tagFg,
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF717786)),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.submittedLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF717786),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (item.scorePercent > 0) ...[
                          SizedBox(width: 8),
                          Text(
                            '${item.scorePercent}%',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: ModuleUiHelper.scoreColor(item.scorePercent),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF53C8C1),
                foregroundColor: const Color(0xFF1A1C1C),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.tr('Review Now'),
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                  SizedBox(width: 6),
                  const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF1A1C1C)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
