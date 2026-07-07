// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

import '../../../../settings/presentation/screens/settings_screen.dart';

/// Parent settings — same UI as student/teacher settings; parent bottom nav only.
class parentsSettingsScreen extends StatelessWidget {
  const parentsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen(shell: SettingsShell.parent);
  }
}
