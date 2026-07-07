import 'package:flutter/material.dart';
import '../constants/app_assets.dart';

class PhonoShell extends StatelessWidget {
  final String stepLabel;
  final Widget child;

  const PhonoShell({super.key, required this.stepLabel, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (stepLabel.isNotEmpty) ...[
            Text(
              stepLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withOpacity(.38),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),
          ],
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Image.asset(
                        AppAssets.bottomimage,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: child,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}