// ignore_for_file: unreachable_switch_case

import 'package:flutter/material.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/add_students.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/chose_your_class.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/class_created.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/class_setup.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/create_new_class.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/message_parents.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/message_parents_individual.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/personal_info.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/professional_profile.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/assignment_detail.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/review_accessment.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/review_assignment.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/select_recipients.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/teacher_assignments_list.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/teachers_assign_module.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/teachers_detail.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/teachers_struggling_students.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/setup_complete.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/teacher_classes.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/teacher_resource_library.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/celebration_report_screen.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/Teachersscreens/teachers_dashboard_screen.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/screens/ParentsScreen/connected_child.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/screens/ParentsScreen/learning_adventure.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/screens/ParentsScreen/parents_dashboard_screen.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/screens/ParentsScreen/parents_personal_info.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/screens/ParentsScreen/parents_reports.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/screens/ParentsScreen/parents_setup_complete.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/screens/ParentsScreen/link_child_account_screen.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/screens/ParentsScreen/parent_recent_quests_screen.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/screens/ParentsScreen/parents_status.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/screens/login_screen.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:phonoquest_signup_flow/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:phonoquest_signup_flow/core/router/route_query.dart';
import 'package:phonoquest_signup_flow/core/network/api_request_coordinator.dart';
import 'package:phonoquest_signup_flow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:phonoquest_signup_flow/features/journey/alphabet_lounge.dart';
import 'package:phonoquest_signup_flow/features/journey/alphabet_lounge_hero.dart';
import 'package:phonoquest_signup_flow/features/journey/alphabet_lounge_letters_play.dart';
import 'package:phonoquest_signup_flow/features/journey/alphabet_lounge_letters_play_sound.dart';
import 'package:phonoquest_signup_flow/features/journey/blend_forest.dart';
import 'package:phonoquest_signup_flow/features/journey/blend_forest_complete.dart';
import 'package:phonoquest_signup_flow/features/journey/blend_forest_detail.dart';
import 'package:phonoquest_signup_flow/features/journey/blend_forest_sound.dart';
import 'package:phonoquest_signup_flow/features/journey/great_job.dart';
import 'package:phonoquest_signup_flow/features/journey/interactive_smart_chart.dart';
import 'package:phonoquest_signup_flow/features/journey/journey.dart';
import 'package:phonoquest_signup_flow/features/journey/phonics_cards.dart';
import 'package:phonoquest_signup_flow/features/journey/phonics_cards_detail.dart';
import 'package:phonoquest_signup_flow/features/journey/phonics_learning.dart';
import 'package:phonoquest_signup_flow/features/journey/practice_mode.dart';
import 'package:phonoquest_signup_flow/features/journey/vowel_learning.dart';
import 'package:phonoquest_signup_flow/features/journey/vowel_learning_complete.dart';
import 'package:phonoquest_signup_flow/features/journey/vowel_learning_detail.dart';
import 'package:phonoquest_signup_flow/features/settings/presentation/screens/account_details.dart';
import 'package:phonoquest_signup_flow/features/settings/presentation/screens/change_password_screen.dart';
import 'package:phonoquest_signup_flow/features/settings/presentation/screens/settings_screen.dart';
import 'package:phonoquest_signup_flow/features/notifications/presentation/role_aware_notifications_screen.dart';
import 'package:phonoquest_signup_flow/features/settings/presentation/screens/language.dart';
import 'package:phonoquest_signup_flow/features/settings/presentation/screens/sound_screen.dart';
import 'package:phonoquest_signup_flow/features/settings/presentation/screens/accessibility_screen.dart';
import 'package:phonoquest_signup_flow/features/settings/presentation/screens/help_support.dart';
import 'package:phonoquest_signup_flow/features/settings/presentation/screens/give_feedback.dart';
import 'package:phonoquest_signup_flow/features/settings/presentation/screens/legal_policies_screen.dart';
import 'package:phonoquest_signup_flow/features/settings/presentation/screens/app_version.dart';
import 'package:phonoquest_signup_flow/features/settings/presentation/screens/invite_friend.dart';
import 'package:phonoquest_signup_flow/features/progress/presentation/screens/student_progress.dart';
import '../../features/home/presentation/screens/home_placeholder_screen.dart';
import '../../features/payment/presentation/screens/payment_screen.dart';
import '../../features/quiz/presentation/screens/quiz_screen.dart';
import '../../features/rewards/presentation/screens/rewards_screen.dart';
import '../../features/subscription/presentation/screens/subscription_management_screen.dart';
import '../../shared/widgets/parent_main_shell.dart';
import '../../shared/widgets/student_main_shell.dart';
import '../../shared/widgets/teacher_main_shell.dart';
import '../../features/home/presentation/screens/splash_screen.dart';
import '../../features/auth/domain/assignment_creation_draft.dart';
import '../../features/auth/domain/class_creation_draft.dart';
import '../../features/auth/domain/parent_registration_draft.dart';
import '../../features/auth/domain/teacher_registration_draft.dart';
import '../../features/signup/domain/student_registration_draft.dart';
import '../../features/signup/presentation/screens/signup_details_screen.dart';
import '../../features/signup/presentation/screens/signup_pace_screen.dart';
import '../../features/signup/presentation/screens/student_pace_screen.dart';
import '../../features/signup/presentation/screens/signup_role_screen.dart';

class AppRouter {
  static const signupRole = '/signup-role';
  static const signupDetails = '/signup-details';
  static const signupPace = '/signup-pace';
  static const studentPace = '/student-pace';
  static const splash = '/splash';
  static const home = '/home';
  static const dashboard = '/dashboard';
  static const alphabet = '/alphabet';
  static const blends = '/blends';
  static const vowels = '/vowels';
  static const smartChart = '/smart-chart';
  static const wordBuilder = '/word-builder';
  static const practice = '/practice';
  static const quiz = '/quiz';
  static const progress = '/progress';
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const parentDashboard = '/parent-dashboard';
  static const teacherDashboard = '/teacher-dashboard';
  static const rewards = '/rewards';
  static const subscription = '/subscription';
  static const payment = '/payment';
  static const accessibility = '/accessibility';
  static const language = '/language';
  static const soundAudio = '/sound-audio';
  static const inviteFriend = '/invite-friend';
  static const giveFeedback = '/give-feedback';
  static const helpSupport = '/help-support';
  static const termsPolicies = '/terms-policies';
  static const termsPrivacy = '/terms-privacy';
  static const appVersion = '/app-version';
  static const futureScan = '/future-scan';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const verifyEmail = '/verify-email';
  static const password = '/password';
  static const accountdetails = '/accountdetails';
  static const journey = '/journey';
  static const vowelslearning = '/vowelslearning';
  static const blendforest = '/blendforest';
  static const alphabetlounge = '/alphabetlounge';
  static const phonicscards = '/phonicscards';
  static const phonicscardsdetail = '/phonicscardsdetail';
  static const phonicslearning = '/phonicslearning';
  static const greatjob = '/greatjob';
  static const lettersplay = '/lettersplay';
  static const lettersplaysound = '/lettersplaysound';
  static const alphabetloungehero = '/alphabetloungehero';
  static const blendforestdetail = '/blendforestdetail';
  static const blendforestdsound = '/blendforestdsound';
  static const blendforestdcomplete = '/blendforestdcomplete';
  static const vowellearningdetail = '/vowellearningdetail';
  static const vowellearningcomplete = '/vowellearningcomplete';
  // Teachers Screen
  static const personalinfo = '/personalinfo';
  static const classsetup = '/classsetup';
  static const professionalprofile = '/professionalprofile';
  static const setupcomplete = '/setupcomplete';
  static const teachersdashboard = '/teachersdashboard';
  static const teachersclasses = '/teachersclasses';
  static const teachersreports = '/teachersreports';
  static const teacherCelebrationReport = '/teacher-celebration-report';
  static const teacherssettings = '/teacherssettings';
  static const createnewclass = '/createnewclass';
  static const choseyourclass = '/choseyourclass';
  static const addstudentsclass = '/addstudentsclass';
  static const classcreated = '/classcreated';
  static const messageparents = '/messageparents';
  static const messageparentsindividual = '/messageparentsindividual';
  static const reviewaccessment = '/reviewaccessment';
  static const reviewaccesment = '/reviewaccesment';
  static const selectrecipients = '/selectrecipients';
  static const assignmentdetail = '/assignmentdetail';
  static const teacherassignmodule = '/teacherassignmodule';
  static const teacherassignmentslist = '/teacherassignmentslist';
  static const teachersStrugglingStudents = '/teachersStrugglingStudents';
  static const teachersdetail = '/teachersdetail';
  static const teacherlibrary = '/teacherlibrary';
  // parents Screen
  static const parentspersonalinfo = '/parentspersonalinfo';
  static const connectedchild = '/connectedchild';
  static const learningadventure = '/learningadventure';
  static const parentssetupcomplete = '/parentssetupcomplete';
  static const parentsdashboardscreen = '/parentsdashboardscreen';
  static const parentssettingscreen = '/parentssettingscreen';
  static const parentsstatusscreen = '/parentsstatusscreen';
  static const parentsreportsscreen = '/parentsreportsscreen';
  static const parentLinkChildAccount = '/parentlinkchildaccount';
  static const parentrecentquests = '/parentrecentquests';

  /// Push Link Child screen (works on web + mobile; avoids named-route edge cases).
  static Future<bool?> pushLinkChildAccount(BuildContext context) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        settings: const RouteSettings(name: parentLinkChildAccount),
        builder: (_) => const LinkChildAccountScreen(),
      ),
    );
  }

  /// Pops back to [dashboard] when it is in the stack; otherwise replaces the
  /// current route. Avoids `(route) => false`, which can leave a blank page on web.
  static void navigateToDashboard(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) => route.settings.name == dashboard || route.isFirst,
    );
    if (ModalRoute.of(context)?.settings.name != dashboard) {
      Navigator.of(context).pushReplacementNamed(dashboard);
    }
  }

  /// Returns to alphabet lounge hub, or opens it when missing from the stack (e.g. web deep link).
  static void navigateToAlphabetLounge(BuildContext context) {
    ApiRequestCoordinator.invalidate(pathContains: '/alphabet');
    Navigator.of(context).popUntil(
      (route) => route.settings.name == alphabet || route.isFirst,
    );
    if (ModalRoute.of(context)?.settings.name != alphabet) {
      Navigator.of(context).pushReplacementNamed(alphabet);
    }
  }

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case signupRole:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const SignupRoleScreen());
      case signupDetails:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const SignupDetailsScreen());
      case signupPace:
        final paceArgs = routeSettings.arguments;
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => SignupPaceScreen(
            draft: paceArgs is StudentRegistrationDraft ? paceArgs : null,
          ),
        );
      case studentPace:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const StudentPaceScreen());
      case splash:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const SplashScreen());
      case home:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const HomePlaceholderScreen());
      case dashboard:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => StudentMainShell(initialIndex: StudentMainShell.indexForRoute(routeSettings.name)),
        );
      case login:
        final roleArg = routeSettings.arguments;
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => LoginScreen(initialRole: roleArg is String ? roleArg : null),
        );
      case forgotPassword:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const ForgotPasswordScreen());
      case resetPassword:
        final resetToken = routeSettings.arguments is String
            ? routeSettings.arguments as String
            : RouteQuery.parameter('token');
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => ResetPasswordScreen(initialToken: resetToken),
        );
      case verifyEmail:
        final verifyArgs = routeSettings.arguments;
        String? verifyEmailArg;
        String? verifyTokenArg;
        if (verifyArgs is String) {
          if (verifyArgs.contains('@')) {
            verifyEmailArg = verifyArgs;
          } else {
            verifyTokenArg = verifyArgs;
          }
        }
        verifyTokenArg ??= RouteQuery.parameter('token');
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => VerifyEmailScreen(
            email: verifyEmailArg,
            initialToken: verifyTokenArg,
          ),
        );
      case password:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const ChangePasswordScreen());
      case accountdetails:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const AccountDetailsScreen());
      case journey:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => StudentMainShell(initialIndex: StudentMainShell.indexForRoute(routeSettings.name)),
        );
      case vowelslearning:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const VowelLearningScreen());
      case blendforest:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const BlendForestScreen());
      case alphabet:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const AlphabetLoungeScreen());
      case greatjob:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const greatJobScreen());
      case phonicscardsdetail:
        return MaterialPageRoute(settings: routeSettings,builder: (_) => const PhonicsCardsDetailScreen(),);
      case lettersplay:
        return MaterialPageRoute(settings: routeSettings,builder: (_) => const lettersPlayScreen(),);
      case blends:
      case vowels:
      case smartChart:
         return MaterialPageRoute(settings: routeSettings, builder: (_) => const InteractiveSmartChartScreen());
      case wordBuilder:
      case phonicscards:
         return MaterialPageRoute(settings: routeSettings, builder: (_) => const PhnoicsCardsScreen());
      case practice:
         return MaterialPageRoute(settings: routeSettings, builder: (_) => const PracticeModeScreen());
      case phonicslearning:
         return MaterialPageRoute(settings: routeSettings, builder: (_) => const PhonicsLearningScreen());
      case lettersplaysound:
         return MaterialPageRoute(settings: routeSettings, builder: (_) => const lettersPlaySoundScreen());
      case alphabetloungehero:
         return MaterialPageRoute(settings: routeSettings, builder: (_) => const alphabetLoungeHeroScreen());
      case blendforestdetail:
         return MaterialPageRoute(settings: routeSettings, builder: (_) => const blendForestDetailScreen());
      case blendforestdsound:
         return MaterialPageRoute(settings: routeSettings, builder: (_) => const blendForesrSoundScreen());
      case blendforestdcomplete:
         return MaterialPageRoute(settings: routeSettings, builder: (_) => const blendForesrCompleteScreen());
      case vowellearningdetail:
         return MaterialPageRoute(settings: routeSettings, builder: (_) => const VowelLearningDetailScreen());
      case vowellearningcomplete:
         return MaterialPageRoute(settings: routeSettings, builder: (_) => const viewLearningCompleteScreen());
      case quiz:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const QuizScreen());
      case progress:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => StudentMainShell(initialIndex: StudentMainShell.indexForRoute(routeSettings.name)),
        );
      case notifications:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const RoleAwareNotificationsScreen());
      case settings:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => StudentMainShell(initialIndex: StudentMainShell.indexForRoute(routeSettings.name)),
        );
      case subscription:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const SubscriptionManagementScreen(),
        );
      case parentDashboard:
      case teacherDashboard:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const HomePlaceholderScreen());
      case rewards:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const RewardsScreen());
      case payment:
        final planArg = routeSettings.arguments;
        final planCode = planArg is String && planArg.isNotEmpty ? planArg : 'intermediate';
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => PaymentScreen(planCode: planCode),
        );
      case accessibility:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const accessbilityScreen());
      case language:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const languageScreen());
      case soundAudio:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const SoundAudioScreen());
      case inviteFriend:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const InviteFriendScreen());
      case giveFeedback:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const giveFeedbackScreen());
      case helpSupport:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const helpSupportScreen());
      case termsPolicies:
      case termsPrivacy:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const LegalPoliciesScreen(),
        );
      case appVersion:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const appVersionScreen());
      case futureScan:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const HomePlaceholderScreen());
      // Teachers route
      case personalinfo:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const PersonalInfoScreen());
      case classsetup:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => classSetupScreen(
            draft: routeSettings.arguments is TeacherRegistrationDraft
                ? routeSettings.arguments as TeacherRegistrationDraft
                : null,
          ),
        );
      case professionalprofile:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => professionalProfileScreen(
            draft: routeSettings.arguments is TeacherRegistrationDraft
                ? routeSettings.arguments as TeacherRegistrationDraft
                : null,
          ),
        );
      case setupcomplete:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const setupCompleteScreen());
      case teachersdashboard:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => TeacherMainShell(initialIndex: TeacherMainShell.indexForRoute(routeSettings.name)),
        );
      case teachersclasses:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => TeacherMainShell(initialIndex: TeacherMainShell.indexForRoute(routeSettings.name)),
        );
      case teachersreports:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => TeacherMainShell(initialIndex: TeacherMainShell.indexForRoute(routeSettings.name)),
        );
      case teacherCelebrationReport:
        final classIdArg = routeSettings.arguments;
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => CelebrationReportScreen(
            classId: classIdArg is int ? classIdArg : null,
          ),
        );
      case teacherssettings:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => TeacherMainShell(initialIndex: TeacherMainShell.indexForRoute(routeSettings.name)),
        );
      case createnewclass:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const createNewClasseScreen());
      case choseyourclass:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => choseYourClasseScreen(
            draft: routeSettings.arguments is ClassCreationDraft
                ? routeSettings.arguments as ClassCreationDraft
                : null,
          ),
        );
      case addstudentsclass:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => addStudentsScreen(
            draft: routeSettings.arguments is ClassCreationDraft
                ? routeSettings.arguments as ClassCreationDraft
                : null,
          ),
        );
      case classcreated:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const classCreatedScreen());
      case messageparents:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const messageParentsScreen());
     case messageparentsindividual:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const messageParentsIndividualScreen());
      case reviewaccessment:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const reviewAssignmentScreen());
      case selectrecipients:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => SelectRecipientsScreen(
            draft: routeSettings.arguments is AssignmentCreationDraft
                ? routeSettings.arguments as AssignmentCreationDraft
                : null,
          ),
        );
      case reviewaccesment:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => ReviewAccessmentScreen(
            draft: routeSettings.arguments is AssignmentCreationDraft
                ? routeSettings.arguments as AssignmentCreationDraft
                : null,
          ),
        );
      case assignmentdetail:
        final detailArgs = routeSettings.arguments;
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => AccessmentDetailScreen(
            assignmentId: detailArgs is int
                ? detailArgs
                : (detailArgs is AssignmentCreationDraft ? detailArgs.assignmentId : null),
          ),
        );
      case teacherassignmodule:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const AssignNewModuleScreen());
      case teacherassignmentslist:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const TeacherAssignmentsListScreen());
      case teachersStrugglingStudents:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const teachersStrugglingStudentsScreen());
      case teachersdetail:
        final studentIdArg = routeSettings.arguments;
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => teachersDetailScreen(
            studentId: studentIdArg is int ? studentIdArg : null,
          ),
        );
      case teacherlibrary:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const TeacherResourceLibraryScreen(),
        );
      case parentspersonalinfo:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const ParentsPersonalInfoScreen());
      case connectedchild:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => ConnectedChildScreen(
            draft: routeSettings.arguments is ParentRegistrationDraft
                ? routeSettings.arguments as ParentRegistrationDraft
                : null,
          ),
        );
      case learningadventure:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => LearningAdventureScreen(
            draft: routeSettings.arguments is ParentRegistrationDraft
                ? routeSettings.arguments as ParentRegistrationDraft
                : null,
          ),
        );
      case parentssetupcomplete:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const parentssetupCompleteScreen());
      case parentsdashboardscreen:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => ParentMainShell(initialIndex: ParentMainShell.indexForRoute(routeSettings.name)),
        );
      case parentssettingscreen:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => ParentMainShell(initialIndex: ParentMainShell.indexForRoute(routeSettings.name)),
        );
      case parentsstatusscreen:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => ParentMainShell(initialIndex: ParentMainShell.indexForRoute(routeSettings.name)),
        );
      case parentLinkChildAccount:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const LinkChildAccountScreen(),
        );
      case parentrecentquests:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const ParentRecentQuestsScreen(),
        );
      case parentsreportsscreen:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => ParentMainShell(initialIndex: ParentMainShell.indexForRoute(routeSettings.name)),
        );
      default:
        return MaterialPageRoute(settings: routeSettings, builder: (_) => const SignupRoleScreen());
    }
  }
}
