import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class RoleTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const RoleTab({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppTheme.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : Colors.black.withOpacity(.65),
            ),
          ),
        ),
      ),
    );
  }
}
