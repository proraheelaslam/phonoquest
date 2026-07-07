import 'package:flutter/material.dart';

class PrimaryCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  const PrimaryCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(15),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
