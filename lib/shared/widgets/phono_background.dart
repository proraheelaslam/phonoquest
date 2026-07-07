import 'package:flutter/material.dart';
import '../constants/app_assets.dart';
import '../../core/theme/app_theme.dart';

class PhonoBackground extends StatelessWidget {
  final Widget child;

  const PhonoBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      body: Stack(
        children: [
          Positioned(top: 86, left: 32, child: Image.asset(AppAssets.ellipseYellow, width: 170)),
          Positioned(top: 295, left: 58, child: Image.asset(AppAssets.ellipsePink, width: 78)),
          Positioned(top: 250, right: 38, child: Image.asset(AppAssets.ellipseTeal, width: 104)),
          Positioned(top: 168, right: -12, child: _chip(const Color(0xFFFFF0CF), 24, 82)),
          Positioned(top: 370, left: -6, child: _chip(const Color(0xFFE8CDF8), 24, 86)),
          Positioned(top: 596, right: -4, child: _chip(const Color(0xFFCFF9D8), 20, 92)),
          const Positioned(left: 0, right: 0, bottom: 0, child: _BottomWaves()),
          SafeArea(child: child),
        ],
      ),
    );
  }

  Widget _chip(Color color, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _BottomWaves extends StatelessWidget {
  const _BottomWaves();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: Stack(
        children: [
          Positioned(left: -10, right: 120, bottom: 12, child: _wave(const Color(0xFFF4D9DF), 52)),
          Positioned(left: 60, right: -10, bottom: 0, child: _wave(const Color(0xFFD6EDF0), 72)),
          Positioned(left: -24, right: -24, bottom: -26, child: _wave(const Color(0xFFF1E7D8), 74)),
        ],
      ),
    );
  }

  Widget _wave(Color color, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(90)),
    );
  }
}
