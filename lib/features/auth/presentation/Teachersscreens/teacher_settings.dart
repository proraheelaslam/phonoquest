// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

import '../../../settings/presentation/screens/settings_screen.dart';

/// Teacher settings — same UI and sub-pages as student settings; teacher bottom nav only.
class teacherSettingsScreen extends StatelessWidget {
  const teacherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen(shell: SettingsShell.teacher);
  }
}
