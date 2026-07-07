import '../../../core/router/app_router.dart';

/// Maps backend module `code` to Flutter route keys used by [studentModuleRoute].
String moduleRouteKeyForCode(String code) {
  switch (code) {
    case 'alphabet_lounge':
      return 'alphabet';
    case 'blend_forest':
      return 'blendforest';
    case 'vowel_learning':
      return 'vowelslearning';
    case 'phonics_cards':
    case 'phonicscards':
      return 'phonicscards';
    case 'smart_chart':
    case 'interactive_smart_chart':
      return 'smart-chart';
    case 'sound_learning':
      return 'phonicslearning';
    case 'listen_tap':
      return 'phonicscards';
    case 'practice':
      return 'practice';
    default:
      return 'alphabet';
  }
}

/// Maps backend module `route` keys to Flutter named routes.
String studentModuleRoute(String routeKey) {
  switch (routeKey) {
    case 'alphabet':
      return AppRouter.alphabet;
    case 'blendforest':
      return AppRouter.blendforest;
    case 'vowelslearning':
      return AppRouter.vowelslearning;
    case 'phonicscards':
      return AppRouter.phonicscards;
    case 'phonicslearning':
      return AppRouter.phonicslearning;
    case 'smart-chart':
      return AppRouter.smartChart;
    case 'practice':
      return AppRouter.practice;
    case 'journey':
      return AppRouter.journey;
    case 'progress':
      return AppRouter.progress;
    default:
      return AppRouter.alphabet;
  }
}

String adventureAssetForCode(String code) {
  switch (code) {
    case 'blend_forest':
      return 'assets/images/journeyimage.png';
    case 'vowel_learning':
      return 'assets/images/vowelimage.png';
    case 'phonics_cards':
      return 'assets/images/exploreimage.png';
    default:
      return 'assets/images/exploreimage.png';
  }
}
