import 'package:flutter/material.dart';

import '../screens/ParentsScreen/parents_reports.dart';

class TeacherResourceLibraryScreen extends StatelessWidget {
  const TeacherResourceLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const parentsReportsScreen(forTeacher: true);
  }
}
