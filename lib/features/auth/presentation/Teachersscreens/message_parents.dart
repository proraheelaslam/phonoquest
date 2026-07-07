// ignore_for_file: deprecated_member_use, prefer_const_constructors, sized_box_for_whitespace, camel_case_types

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../data/teacher_messages_models.dart';
import '../../data/teacher_messages_repository.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../core/l10n/app_language_controller.dart';

class messageParentsScreen extends StatefulWidget {
  const messageParentsScreen({super.key});

  @override
  State<messageParentsScreen> createState() => _messageParentsScreenState();
}

class _messageParentsScreenState extends State<messageParentsScreen> {
  final _repo = TeacherMessagesRepository();
  final _messageController = TextEditingController();

  List<ClassRecipientSummary> _classes = [];
  List<RecentMessageItem> _recent = [];
  ClassRecipientSummary? _selectedClass;
  String _selectedMessageType = 'Class Update';
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _repo.fetchClassRecipients(),
        _repo.fetchRecentMessages(),
      ]);
      if (!mounted) return;
      final classes = results[0] as List<ClassRecipientSummary>;
      setState(() {
        _classes = classes;
        _selectedClass = classes.isNotEmpty ? classes.first : null;
        _recent = results[1] as List<RecentMessageItem>;
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

  Future<void> _sendMessage() async {
    final selected = _selectedClass;
    final text = _messageController.text.trim();
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Create a class with students first.'))),
      );
      return;
    }
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Write a message before sending.'))),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      await _repo.sendClassMessage(
        classId: selected.classId,
        messageType: messageTypeApiFromUi(_selectedMessageType),
        message: text,
      );
      if (!mounted) return;
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Message sent successfully'))),
      );
      final recent = await _repo.fetchRecentMessages();
      if (!mounted) return;
      setState(() => _recent = recent);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Could not send message.')),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _pickClass() {
    if (_classes.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(context.tr('Select class'),
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              for (final item in _classes)
                ListTile(
                  title: Text(item.className, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${item.recipientsCount} Recipients'),
                  onTap: () {
                    setState(() => _selectedClass = item);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selected = _selectedClass;

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      child: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.tr('Message Parents'),
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1A1C1C),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(context.tr('Send class update'),
                              style: textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF717786),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Image.asset(AppAssets.parentsimage, width: 78, height: 58, fit: BoxFit.contain),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF3F3F3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('Send To'),
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1C1C),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: _sendToTab(context, index: 0, label: 'Classes')),
                              Expanded(child: _sendToTab(context, index: 1, label: 'Individual')),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        InkWell(
                          onTap: _classes.isEmpty ? null : _pickClass,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.groups_rounded, color: Colors.white, size: 20),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selected?.recipientLabel ?? 'No class available',
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF1A1C1C),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        selected != null
                                            ? '${selected.recipientsCount} Recipients'
                                            : 'Add students to a class first',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: const Color(0xFF717786),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF717786)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF3F3F3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('Message Type'),
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1C1C),
                          ),
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _messageTypeChip(context, label: context.tr('Class Update'), color: Color(0xFF3B82F6)),
                            _messageTypeChip(context, label: context.tr('Progress Report'), color: Color(0xFFE5E7EB)),
                            _messageTypeChip(context, label: 'Reminder', color: const Color(0xFFE5E7EB)),
                            _messageTypeChip(context, label: 'Milestone', color: const Color(0xFFFCC419)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
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
                          children: [
                            Text(context.tr('Draft Message'),
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A1C1C),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Color(0xFF717786)),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 220,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _messageController,
                            maxLines: null,
                            expands: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: selected != null
                                  ? 'Write your update to ${selected.className} parents...'
                                  : 'Write your message...',
                              hintStyle: textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: (_sending || selected == null) ? null : _sendMessage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF43C2BD),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: _sending
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.send_rounded, size: 18, color: Color(0xFF1A1C1C)),
                                      SizedBox(width: 10),
                                      Text(context.tr('SEND MESSAGE'),
                                        style: textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF1A1C1C),
                                          letterSpacing: .6,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCC419),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(context.tr('Recent Messages'),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1A1C1C),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (_recent.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(context.tr('No messages sent yet.'),
                        style: textTheme.bodySmall?.copyWith(color: const Color(0xFF717786)),
                      ),
                    )
                  else
                    ..._recent.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _recentMessageCard(context, item: item),
                      );
                    }),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _sendToTab(BuildContext context, {required int index, required String label}) {
    final textTheme = Theme.of(context).textTheme;
    final bool selected = index == 0;

    return InkWell(
      onTap: () {
        if (index == 1) {
          Navigator.pushNamed(context, AppRouter.messageparentsindividual);
          return;
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF47495) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: selected ? const Color(0xFF1A1C1C) : const Color(0xFF717786),
          ),
        ),
      ),
    );
  }

  Widget _messageTypeChip(BuildContext context, {required String label, required Color color}) {
    final textTheme = Theme.of(context).textTheme;
    final bool selected = _selectedMessageType == label;

    Color bg;
    Color fg;
    Color border;
    if (label == 'Milestone') {
      bg = const Color(0xFFFFF1C2);
      fg = const Color(0xFF8A5A00);
      border = const Color(0xFFFCC419);
    } else if (selected) {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1D4ED8);
      border = const Color(0xFF93C5FD);
    } else {
      bg = const Color(0xFFF3F4F6);
      fg = const Color(0xFF717786);
      border = const Color(0xFFE5E7EB);
    }

    return InkWell(
      onTap: () => setState(() => _selectedMessageType = label),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900, color: fg),
        ),
      ),
    );
  }

  Widget _recentMessageCard(BuildContext context, {required RecentMessageItem item}) {
    final textTheme = Theme.of(context).textTheme;
    final tags = <_Tag>[
      _Tag(
        label: item.messageTypeLabel,
        bg: item.messageType == 'milestone'
            ? const Color(0xFFFCC419)
            : const Color(0xFFDBEAFE),
        fg: item.messageType == 'milestone'
            ? const Color(0xFF1A1C1C)
            : const Color(0xFF1D4ED8),
      ),
    ];
    if (item.isClassMessage && (item.recipientsCount ?? 0) > 0) {
      tags.add(
        _Tag(
          label: '${item.recipientsCount} Read',
          bg: const Color(0xFFFCC419),
          fg: const Color(0xFF1A1C1C),
        ),
      );
    }

    final icon = item.isClassMessage ? Icons.campaign_rounded : Icons.backpack_rounded;
    final iconBg = item.isClassMessage ? const Color(0xFFDBEAFE) : const Color(0xFFD1FAE5);

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
                width: 40,
                height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: const Color(0xFF1A1C1C)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.toLabel,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1A1C1C),
                            ),
                          ),
                        ),
                        Text(
                          item.sentAtLabel,
                          style: textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF717786),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      item.messagePreview,
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF717786),
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: t.bg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      t.label,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: t.fg,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Tag {
  final String label;
  final Color bg;
  final Color fg;

  const _Tag({required this.label, required this.bg, required this.fg});
}
