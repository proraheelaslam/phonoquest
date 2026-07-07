// ignore_for_file: deprecated_member_use, prefer_const_constructors, sized_box_for_whitespace, camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/auth/auth_token_storage.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/downloads/printable_downloader.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/teacher_messages_models.dart';
import '../../data/teacher_messages_repository.dart';
import '../../data/teacher_reports_models.dart';
import '../../data/teacher_reports_repository.dart';
import '../../data/teacher_student_detail_models.dart';
import '../../data/teacher_student_detail_repository.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../core/l10n/app_language_controller.dart';

class teachersDetailScreen extends StatefulWidget {
  const teachersDetailScreen({super.key, this.studentId});

  final int? studentId;

  @override
  State<teachersDetailScreen> createState() => _teachersDetailScreenState();
}

class _teachersDetailScreenState extends State<teachersDetailScreen> {
  final _repo = TeacherStudentDetailRepository();
  final _reportsRepo = TeacherReportsRepository();
  final _messagesRepo = TeacherMessagesRepository();

  TeacherStudentDetail? _detail;
  List<StudentPerformanceRow> _roster = const [];
  int? _selectedStudentId;
  bool _loading = true;
  bool _loadingRoster = false;
  bool _exporting = false;
  bool _messaging = false;

  @override
  void initState() {
    super.initState();
    _selectedStudentId = widget.studentId;
    if (_selectedStudentId != null) {
      _loadDetail();
    } else {
      _loadRoster();
    }
  }

  Future<void> _loadRoster() async {
    setState(() {
      _loadingRoster = true;
      _loading = true;
    });
    try {
      final reports = await _reportsRepo.fetchReports();
      if (!mounted) return;
      final students = reports.students;
      setState(() {
        _roster = students;
        _loadingRoster = false;
        _loading = false;
      });
      if (students.length == 1) {
        _selectStudent(students.first.studentId);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingRoster = false;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingRoster = false;
          _loading = false;
        });
      }
    }
  }

  void _selectStudent(int studentId) {
    setState(() {
      _selectedStudentId = studentId;
      _detail = null;
    });
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final id = _selectedStudentId;
    if (id == null) return;
    setState(() => _loading = true);
    try {
      final detail = await _repo.fetchStudentDetail(id);
      if (!mounted) return;
      setState(() {
        _detail = detail;
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

  Future<void> _exportPdf() async {
    final detail = _detail;
    if (detail == null || _exporting) return;
    setState(() => _exporting = true);
    try {
      final token = await AuthTokenStorage.instance.readAccessToken();
      final path = _repo.reportPdfPath(detail.studentId);
      final url = '${AppConfig.apiBaseUrl}$path';
      await downloadPrintablePdf(
        url: url,
        filename: detail.reportPdfFilename,
        headers: {
          'Accept': 'application/pdf',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Progress report downloaded.')),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } on PrintableDownloadException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Could not export PDF.')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _messageParent() async {
    final detail = _detail;
    if (detail == null || _messaging) return;

    if (!detail.parentLinked) {
      final proceed = await _showNoParentLinkedSheet(detail);
      if (proceed != true || !mounted) return;
    }

    await _sendParentMessage(detail);
  }

  Future<void> _sendParentMessage(TeacherStudentDetail detail) async {
    setState(() => _messaging = true);
    try {
      final result = await _messagesRepo.sendIndividualMessage(
        studentId: detail.studentId,
        messageType: 'progress_report',
        message: detail.messageParentSuggestion,
      );
      if (!mounted) return;
      _showMessageResultSnackBar(result, detail.displayName);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } finally {
      if (mounted) setState(() => _messaging = false);
    }
  }

  void _showMessageResultSnackBar(IndividualMessageResult result, String displayName) {
    final text = result.parentLinked
        ? '${context.tr('Message sent to ')}$displayName${context.tr("'s parent.")}'
        : '${context.tr('Message saved for ')}$displayName${context.tr(" — will deliver when a parent links.")}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: result.parentLinked ? const Color(0xFF10B981) : const Color(0xFF8A5A00),
      ),
    );
  }

  Future<bool?> _showNoParentLinkedSheet(TeacherStudentDetail detail) {
    final questCode = detail.studentQuestCode?.trim();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final textTheme = Theme.of(sheetContext).textTheme;
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('No parent linked yet'),
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 10),
              Text(
                detail.parentLinkHint ??
                    context.tr(
                      'Share the Quest ID with the family. Your message will be saved and delivered when a parent connects.',
                    ),
                style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563)),
              ),
              if (questCode != null && questCode.isNotEmpty) ...[
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('Student Quest ID'),
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              questCode,
                              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: questCode));
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            SnackBar(content: Text(context.tr('Quest ID copied.'))),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: Text(context.tr('Copy')),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext, false),
                      child: Text(context.tr('Cancel')),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF47495),
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        context.tr('Save message'),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _parentLinkBanner(TeacherStudentDetail detail, TextTheme textTheme) {
    if (detail.parentLinked) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                context.tr('Parent connected — messages deliver instantly.'),
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF065F46),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1C2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFF8A5A00)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              detail.parentLinkHint ??
                  context.tr('No parent linked. Share Quest ID so family can connect.'),
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8A5A00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _focusTagColors(String tagKey) {
    switch (tagKey) {
      case 'reviewing':
        return (const Color(0xFFFFF1C2), const Color(0xFF8A5A00));
      case 'on_track':
        return (const Color(0xFFD1FAE5), const Color(0xFF10B981));
      default:
        return (const Color(0xFFFFE4E6), const Color(0xFFDC2626));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final detail = _detail;

    if (_selectedStudentId == null && !_loading && !_loadingRoster) {
      return AppScaffold(
        title: '',
        backgroundAsset: AppAssets.dashboardimage,
        showAppBar: false,
        automaticallyImplyLeading: false,
        wrapInScrollView: false,
        child: _buildStudentPicker(context),
      );
    }

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      wrapInScrollView: false,
      child: _loading
          ? Center(child: CircularProgressIndicator())
          : detail == null
              ? Center(
                  child: TextButton(
                    onPressed: _loadDetail,
                    child: Text(context.tr('Retry loading student detail')),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDetail,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppScaffold.pageScrollPadding(context),
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
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                context.tr('Student Detail'),
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF1A1C1C),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF3F3F3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: const Color(0xFFE5E7EB),
                                    child: Text(
                                      detail.initials,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 20,
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
                                          detail.displayName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF1A1C1C),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          detail.subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: const Color(0xFF717786),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: detail.growthPositive
                                          ? const Color(0xFFD1FAE5)
                                          : const Color(0xFFFFF1C2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${detail.masteryPercent}%',
                                          style: textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: detail.growthPositive
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFF8A5A00),
                                          ),
                                        ),
                                        Text(
                                          'Mastery',
                                          style: textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: detail.growthPositive
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFF8A5A00),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              _parentLinkBanner(detail, textTheme),
                              SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _exporting ? null : _exportPdf,
                                      icon: _exporting
                                          ? SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.download_outlined, size: 18, color: Colors.black),
                                      label: Text(context.tr('Export PDF'),
                                        style: textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF53C8C1),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _messaging ? null : _messageParent,
                                      icon: _messaging
                                          ? SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.mail_outline, size: 18, color: Colors.black),
                                      label: Text(context.tr('Message Parent'),
                                        style: textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFF47495),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF3F3F3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          detail.chartTitle,
                                          style: textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF1A1C1C),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          detail.subtitle,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: const Color(0xFF717786),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: detail.growthPositive
                                          ? const Color(0xFFD1FAE5)
                                          : const Color(0xFFFFF1C2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      detail.growthLabel,
                                      style: textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: detail.growthPositive
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF8A5A00),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              SizedBox(
                                height: 100,
                                child: CustomPaint(
                                  size: const Size(double.infinity, 100),
                                  painter: _LineChartPainter(
                                    ratios: detail.weeklyFluency.map((p) => p.ratio).toList(),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: detail.weeklyFluency
                                    .map(
                                      (p) => Text(
                                        p.dayLabel,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF717786),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF53C8C1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(context.tr('Current Quest'),
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF1A1C1C),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                detail.currentQuestSubtitle,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.black.withOpacity(.65),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 14),
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(.25),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.headset_rounded, color: Color(0xFF1A1C1C)),
                                  ),
                                  SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${detail.currentQuestCompletionPct}%',
                                        style: textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF1A1C1C),
                                        ),
                                      ),
                                      Text(
                                        detail.currentQuestTitle,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: Colors.black.withOpacity(.65),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: (detail.currentQuestCompletionPct / 100).clamp(0.0, 1.0),
                                  backgroundColor: Colors.white.withOpacity(.25),
                                  valueColor: const AlwaysStoppedAnimation(Color(0xFFF47495)),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF3F3F3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF1C2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.adjust_rounded, size: 16, color: Color(0xFFF59E0B)),
                                  ),
                                  SizedBox(width: 10),
                                  Text(context.tr('Focus Areas'),
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1A1C1C),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14),
                              ...detail.focusAreas.map((area) {
                                final colors = _focusTagColors(area.tagKey);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _focusItem(
                                    context,
                                    title: area.title,
                                    tag: area.tag,
                                    tagBg: colors.$1,
                                    tagFg: colors.$2,
                                    description: area.description,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF3F3F3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD1FAE5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.workspace_premium_rounded,
                                      size: 16,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(context.tr('Mastery Collection'),
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1A1C1C),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14),
                              if (detail.masteryItems.isEmpty)
                                Text(context.tr('No mastered skills yet.'),
                                  style: textTheme.bodySmall?.copyWith(color: const Color(0xFF717786)),
                                )
                              else
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: detail.masteryItems.map(_masteryChip).toList(),
                                ),
                              if (detail.masteryTotalCount > 0) ...[
                                SizedBox(height: 12),
                                Center(
                                  child: Text(
                                    'View All (${detail.masteryTotalCount})',
                                    style: textTheme.labelLarge?.copyWith(
                                      color: const Color(0xFFF47495),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStudentPicker(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return RefreshIndicator(
      onRefresh: _loadRoster,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppScaffold.pageScrollPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              SizedBox(height: 8),
              Text(context.tr('Student Detail'),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1C1C),
                ),
              ),
              SizedBox(height: 4),
              Text(context.tr('Select a student to view progress, focus areas, and export a report.'),
                style: textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF717786),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              if (_roster.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(context.tr('No students in your classes yet.'),
                      style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280)),
                    ),
                  ),
                )
              else
                ..._roster.map((student) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => _selectStudent(student.studentId),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF3F3F3)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFFE5E7EB),
                              child: Text(
                                student.initials,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
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
                                    student.displayName,
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1A1C1C),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '${student.lastActiveLabel} • ${student.masteryPercent}% mastery',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF717786),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _focusItem(
    BuildContext context, {
    required String title,
    required String tag,
    required Color tagBg,
    required Color tagFg,
    required String description,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: tagFg,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            description,
            style: textTheme.bodySmall?.copyWith(
              color: const Color(0xFF717786),
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _masteryChip(String label) {
    final isMore = label.startsWith('+');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMore ? const Color(0xFFF3F4F6) : const Color(0xFFFFF1C2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMore) ...[
            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
            SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1C1C),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.ratios});

  final List<double> ratios;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final padding = 8.0;

    if (ratios.isEmpty) return;

    final points = <Offset>[];
    for (var i = 0; i < ratios.length; i++) {
      final x = ratios.length == 1 ? w * 0.5 : w * (i / (ratios.length - 1));
      final y = h - padding - (ratios[i].clamp(0.0, 1.0) * (h - padding * 2));
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final paint = Paint()
      ..color = const Color(0xFF53C8C1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);

    var peakIndex = 0;
    for (var i = 1; i < ratios.length; i++) {
      if (ratios[i] > ratios[peakIndex]) peakIndex = i;
    }
    final peak = points[peakIndex];
    final dotPaint = Paint()..color = Colors.white;
    final borderPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(peak, 5, dotPaint);
    canvas.drawCircle(peak, 5, borderPaint);

    final linePaint = Paint()
      ..color = const Color(0xFFEF4444).withOpacity(.35)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(peak.dx, padding), Offset(peak.dx, h - padding), linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.ratios != ratios;
  }
}
