// ignore_for_file: prefer_const_constructors, camel_case_types, unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phonoquest_signup_flow/core/theme/app_theme.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../shared/constants/app_assets.dart';
import '../../../../../shared/widgets/phono_back_button.dart';
import '../../../../../shared/widgets/phono_shell.dart';
import '../../../../../shared/widgets/primary_button.dart';
import '../../../../../core/l10n/app_language_controller.dart';

class parentssetupCompleteScreen extends StatelessWidget {
  const parentssetupCompleteScreen({super.key});

  Widget _successGraphic() {
    return SizedBox(
      width: 170,
      height: 170,
      child: CustomPaint(
        painter: _SuccessPainter(
          teal: AppTheme.mint,
          pink: AppTheme.pink,
          background: const Color(0xFFFFF5E6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Background SVG Image
            Positioned.fill(
              child: SvgPicture.asset(
                AppAssets.signUpBackground,
                fit: BoxFit.cover,
              ),
            ),

            // Your UI
            SafeArea(
              child: PhonoShell(
                stepLabel: '',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                  child: Column(
                    children: [
                      const Spacer(),
                      Center(child: _successGraphic()),
                      SizedBox(height: 22),
                      Text(context.tr('Setup Complete!'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 28,
                            ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(context.tr("Your parent account is ready. Let's start your\nchild's phonics adventure together."),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const Spacer(),
                      PrimaryButton(
                        label: context.tr('GO TO MY DASHBOARD'),
                        onTap: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRouter.parentsdashboardscreen,
                          (route) => false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessPainter extends CustomPainter {
  final Color teal;
  final Color pink;
  final Color background;

  _SuccessPainter({
    required this.teal,
    required this.pink,
    required this.background,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.46;
    final ringRadius = size.width * 0.30;

    final tealPaint = Paint()
      ..color = teal
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pinkPaint = Paint()
      ..color = pink
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final bgPaint = Paint()..color = background;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      -2.7,
      1.5,
      false,
      tealPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      0.4,
      1.4,
      false,
      tealPaint,
    );

    canvas.drawCircle(center, ringRadius, bgPaint);
    canvas.drawCircle(center, ringRadius, pinkPaint);

    final checkPaint = Paint()
      ..color = pink
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(center.dx - ringRadius * 0.40, center.dy + ringRadius * 0.05);
    path.lineTo(center.dx - ringRadius * 0.10, center.dy + ringRadius * 0.30);
    path.lineTo(center.dx + ringRadius * 0.45, center.dy - ringRadius * 0.25);
    canvas.drawPath(path, checkPaint);
  }

  @override
  bool shouldRepaint(covariant _SuccessPainter oldDelegate) {
    return oldDelegate.teal != teal || oldDelegate.pink != pink || oldDelegate.background != background;
  }
}
