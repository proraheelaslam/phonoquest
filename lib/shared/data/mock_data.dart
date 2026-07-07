import '../../core/router/app_router.dart';
import '../models/app_models.dart';

class MockData {
  static const List<DashboardModule> modules = [
    DashboardModule(title: 'Alphabet', subtitle: 'Interactive letter sounds', route: AppRouter.alphabet, icon: 'A'),
    DashboardModule(title: 'Blends', subtitle: 'sh, th, ch and more', route: AppRouter.blends, icon: 'sh'),
    DashboardModule(title: 'Vowels', subtitle: 'Short, long, and teams', route: AppRouter.vowels, icon: 'oo'),
    DashboardModule(title: 'Smart Chart', subtitle: 'Core phonics explorer', route: AppRouter.smartChart, icon: 'SC'),
    DashboardModule(title: 'Word Builder', subtitle: 'Blend sounds into words', route: AppRouter.wordBuilder, icon: 'WB'),
    DashboardModule(title: 'Practice', subtitle: 'Guided drills', route: AppRouter.practice, icon: 'P'),
    DashboardModule(title: 'Quiz', subtitle: 'Challenges and review', route: AppRouter.quiz, icon: 'Q'),
    DashboardModule(title: 'Progress', subtitle: 'Performance summary', route: AppRouter.progress, icon: 'PR'),
  ];

  static const List<SoundTileModel> alphabet = [
    SoundTileModel(label: 'A', hint: '/a/', example: 'apple'),
    SoundTileModel(label: 'B', hint: '/b/', example: 'ball'),
    SoundTileModel(label: 'C', hint: '/k/', example: 'cat'),
    SoundTileModel(label: 'D', hint: '/d/', example: 'dog'),
    SoundTileModel(label: 'E', hint: '/e/', example: 'egg'),
    SoundTileModel(label: 'F', hint: '/f/', example: 'fish'),
  ];

  static const List<SoundTileModel> blends = [
    SoundTileModel(label: 'sh', hint: '/sh/', example: 'ship'),
    SoundTileModel(label: 'th', hint: '/th/', example: 'thumb'),
    SoundTileModel(label: 'ch', hint: '/ch/', example: 'chair'),
    SoundTileModel(label: 'wh', hint: '/wh/', example: 'whale'),
  ];

  static const List<SoundTileModel> vowels = [
    SoundTileModel(label: 'a_e', hint: 'long a', example: 'cake'),
    SoundTileModel(label: 'ee', hint: 'long e', example: 'tree'),
    SoundTileModel(label: 'oa', hint: 'long o', example: 'boat'),
    SoundTileModel(label: 'oo', hint: 'double o', example: 'moon'),
  ];
}
