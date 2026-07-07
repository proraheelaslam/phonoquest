import 'blend_forest_models.dart';

/// Arguments for [blendForesrSoundScreen] from hub lesson cards.
class BlendSoundScreenArgs {
  const BlendSoundScreenArgs({
    required this.lessonId,
    required this.digraph,
    this.lessonAudioUrl,
    this.words = const [],
  });

  final int lessonId;
  final String digraph;
  final String? lessonAudioUrl;
  final List<BlendWordModel> words;
}
