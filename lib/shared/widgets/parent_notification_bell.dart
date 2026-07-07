import 'package:flutter/material.dart';
import '../../features/auth/data/parent_messages_repository.dart';
import '../../core/router/app_router.dart';

class ParentNotificationBell extends StatefulWidget {
  const ParentNotificationBell({
    super.key,
    this.iconSize = 22,
    this.initialCount,
  });

  final double iconSize;
  final int? initialCount;

  @override
  State<ParentNotificationBell> createState() => _ParentNotificationBellState();
}

class _ParentNotificationBellState extends State<ParentNotificationBell> {
  final _repo = ParentMessagesRepository();
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount ?? 0;
    if (widget.initialCount == null) {
      _loadCount();
    }
  }

  @override
  void didUpdateWidget(covariant ParentNotificationBell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCount != null && widget.initialCount != oldWidget.initialCount) {
      setState(() => _count = widget.initialCount!);
    }
  }

  Future<void> _loadCount() async {
    try {
      final count = await _repo.fetchUnreadCount();
      if (mounted) setState(() => _count = count);
    } catch (_) {}
  }

  Future<void> _openNotifications() async {
    await Navigator.pushNamed(context, AppRouter.notifications);
    if (!mounted) return;
    setState(() => _count = 0);
    if (widget.initialCount == null) {
      _loadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = Icon(Icons.notifications_none_rounded, size: widget.iconSize);
    return IconButton(
      onPressed: _openNotifications,
      icon: _count > 0
          ? Badge(
              label: Text(
                _count > 9 ? '9+' : '$_count',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
              ),
              backgroundColor: const Color(0xFFEF4444),
              child: icon,
            )
          : icon,
    );
  }
}
