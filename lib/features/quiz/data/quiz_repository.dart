import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/api_exception.dart';
import '../../journey/data/practice_models.dart';
import '../../journey/data/practice_repository.dart';
import 'quiz_models.dart';

class QuizRepository {
  QuizRepository({ApiClient? client, PracticeRepository? practiceRepo})
      : _client = client ?? ApiClient(),
        _practiceRepo = practiceRepo ?? PracticeRepository();

  final ApiClient _client;
  final PracticeRepository _practiceRepo;

  Future<QuizHubPayload> fetchHub() async {
    final response = await _client.get('/student/quiz', authorized: true);
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not load quiz challenges.'),
      );
    }
    try {
      return QuizHubPayload.fromRootJson(response.body);
    } on FormatException catch (e) {
      throw ApiException(response.statusCode, e.message);
    }
  }

  Future<ExerciseSubmitResult> submitChallenge({
    required int exerciseId,
    required String selectedCode,
  }) {
    return _practiceRepo.submitExercise(
      exerciseId: exerciseId,
      selectedCode: selectedCode,
    );
  }
}
