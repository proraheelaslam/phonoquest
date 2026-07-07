import 'package:flutter/material.dart';
import '../constants/app_assets.dart';

class PhonoBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const PhonoBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(AppAssets.backIcon, width: 56, height: 56),
    );
  }
}
