import 'package:flutter/material.dart';
import '../../../../shared/widgets/phono_background.dart';
import '../../../../shared/widgets/phono_shell.dart';
import '../../../../core/l10n/app_language_controller.dart';

class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PhonoBackground(
      child: PhonoShell(
        stepLabel: 'Home',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(context.tr('Signup flow completed.\nNext screens can be added one by one.'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
      ),
    );
  }
}
