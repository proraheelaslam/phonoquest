import 'package:flutter/material.dart';

class FeatureChip extends StatelessWidget {
  final String text;
  const FeatureChip(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(text));
  }
}
