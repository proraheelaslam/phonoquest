import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: titleStyle ?? textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(subtitle, style: subtitleStyle ?? textTheme.bodyMedium),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
