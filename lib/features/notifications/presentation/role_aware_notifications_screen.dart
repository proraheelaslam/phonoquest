import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/core/auth/current_user_storage.dart';
import 'package:phonoquest_signup_flow/features/settings/presentation/screens/student_notification.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/screens/ParentsScreen/parent_notification_screen.dart';
import 'package:phonoquest_signup_flow/features/notifications/presentation/teacher_notification_screen.dart';

/// Routes students and parents to the correct notifications screen.
class RoleAwareNotificationsScreen extends StatefulWidget {
  const RoleAwareNotificationsScreen({super.key});

  @override
  State<RoleAwareNotificationsScreen> createState() =>
      _RoleAwareNotificationsScreenState();
}

class _RoleAwareNotificationsScreenState extends State<RoleAwareNotificationsScreen> {
  late final Future<LocalUserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = CurrentUserStorage.instance.readProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocalUserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final role = snapshot.data?.roleName.toLowerCase() ?? '';
        if (role == 'parent') {
          return const parentNotificationScreen();
        }
        if (role == 'teacher') {
          return const TeacherNotificationScreen();
        }
        return const studentNotificationScreen();
      },
    );
  }
}
