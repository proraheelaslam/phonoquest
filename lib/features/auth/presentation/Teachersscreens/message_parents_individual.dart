// ignore_for_file: deprecated_member_use, prefer_const_constructors, sized_box_for_whitespace, camel_case_types

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/shared/constants/app_assets.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/teacher_messages_models.dart';
import '../../data/teacher_messages_repository.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../core/l10n/app_language_controller.dart';

class messageParentsIndividualScreen extends StatefulWidget {
  const messageParentsIndividualScreen({super.key});

  @override
  State<messageParentsIndividualScreen> createState() =>
      _messageParentsIndividualScreenState();
}

class _messageParentsIndividualScreenState extends State<messageParentsIndividualScreen> {
  final _repo = TeacherMessagesRepository();
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  List<ParentSearchItem> _recipients = [];
  bool _loading = true;
  bool _searching = false;
  int _sendToIndex = 1;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadRecipients();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _loadRecipients(query: _searchController.text);
    });
  }

  Future<void> _loadRecipients({String query = ''}) async {
    if (_recipients.isEmpty) {
      setState(() => _loading = true);
    } else {
      setState(() => _searching = true);
    }
    try {
      final list = await _repo.searchIndividualRecipients(query: query);
      if (!mounted) return;
      setState(() {
        _recipients = list;
        _loading = false;
        _searching = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _searching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _searching = false;
        });
      }
    }
  }

  Future<void> _openCompose(ParentSearchItem recipient) async {
    final sent = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _IndividualComposeDialog(recipient: recipient),
    );
    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.tr('Message sent to ')}${recipient.parentLabel}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      title: '',
      backgroundAsset: AppAssets.dashboardimage,
      showAppBar: false,
      automaticallyImplyLeading: false,
      child: SingleChildScrollView(
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
                      Text(context.tr('Message one parent'),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, size: 20, color: Color(0xFF717786)),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: context.tr('Search parents or students...'),
                              hintStyle: textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (_searching)
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
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
                  Text(
                    'Parents',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (_loading)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else if (_recipients.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(context.tr('No students found. Add students to a class first.'),
                        style: textTheme.bodySmall?.copyWith(color: const Color(0xFF717786)),
                      ),
                    )
                  else
                    ..._recipients.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _personRow(context, item: item, onMessage: () => _openCompose(item)),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sendToTab(BuildContext context, {required int index, required String label}) {
    final textTheme = Theme.of(context).textTheme;
    final bool selected = _sendToIndex == index;

    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.pop(context);
          return;
        }
        setState(() => _sendToIndex = index);
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

  Widget _personRow(
    BuildContext context, {
    required ParentSearchItem item,
    required VoidCallback onMessage,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final initial = item.childName.isNotEmpty ? item.childName[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE5E7EB),
            child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.parentLabel,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  item.summary,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF717786),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            height: 34,
            child: ElevatedButton(
              onPressed: onMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43C2BD),
                foregroundColor: const Color(0xFF1A1C1C),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Message',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1C1C),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndividualComposeDialog extends StatefulWidget {
  const _IndividualComposeDialog({required this.recipient});

  final ParentSearchItem recipient;

  @override
  State<_IndividualComposeDialog> createState() => _IndividualComposeDialogState();
}

class _IndividualComposeDialogState extends State<_IndividualComposeDialog> {
  final _repo = TeacherMessagesRepository();
  final _messageController = TextEditingController();
  String _messageType = 'Class Update';
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);
    try {
      await _repo.sendIndividualMessage(
        studentId: widget.recipient.studentId,
        messageType: messageTypeApiFromUi(_messageType),
        message: text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
      );
    } catch (_) {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.recipient.parentLabel,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${context.tr('To: ')}${widget.recipient.childName}', style: const TextStyle(color: Color(0xFF717786))),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Class Update', 'Progress Report', 'Reminder', 'Milestone'].map((label) {
                final selected = _messageType == label;
                return ChoiceChip(
                  label: Text(label, style: const TextStyle(fontSize: 11)),
                  selected: selected,
                  onSelected: (_) => setState(() => _messageType = label),
                );
              }).toList(),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: context.tr('Write your message...'),
                filled: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _sending ? null : () => Navigator.pop(context), child: Text(context.tr('Cancel'))),
        ElevatedButton(
          onPressed: _sending ? null : _send,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43C2BD)),
          child: _sending
              ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(context.tr('Send'), style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}
