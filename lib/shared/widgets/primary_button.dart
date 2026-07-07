import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isBusy;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(colors: [Color(0xFF67D4CF), Color(0xFF59C7C2)]),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF62D2CF).withOpacity(.35),
              blurRadius: 14,
              offset: const Offset(0, 7),
            )
          ],
        ),
        child: TextButton(
          onPressed: isBusy ? null : onTap,
          style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: isBusy
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.ink),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                  ),
                ),
        ),
      ),
    );
  }
}
