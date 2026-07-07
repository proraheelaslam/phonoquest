import 'dart:convert';

import '../../../../core/auth/current_user_storage.dart';
import '../../../../core/l10n/app_language_controller.dart';
import '../../../../core/media/media_image_loader.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error_parser.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_request_coordinator.dart';
import '../models/learner_profile.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetch current user's profile (`GET /profiles/me`, falls back to `GET /auth/me`).
  Future<LearnerProfilePayload> fetchMyProfile({bool forceRefresh = false}) async {
    try {
      final response = await _apiClient.get(
        '/profiles/me',
        authorized: true,
        useCache: !forceRefresh,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final payload = LearnerProfilePayload.fromJson(decoded);
          if (payload.status) {
            await CurrentUserStorage.instance.saveUserMap(payload.data.toJson());
            await AppLanguageController.instance.syncFromProfile(
              userId: payload.data.userId,
              locale: payload.data.locale,
            );
            return payload;
          }
        }
      }

      return _fetchFromAuthMe();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(0, 'Unexpected error: $e');
    }
  }

  Future<LearnerProfilePayload> _fetchFromAuthMe() async {
    final response = await _apiClient.get('/auth/me', authorized: true);
    if (response.statusCode != 200) {
      throw ApiException(response.statusCode, 'Failed to fetch profile');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException(response.statusCode, 'Invalid response from server.');
    }
    final payload = LearnerProfilePayload.fromAuthMe(decoded);
    if (!payload.status) {
      throw ApiException(response.statusCode, 'No profile found');
    }
    await CurrentUserStorage.instance.saveUserMap(payload.data.toJson());
    await AppLanguageController.instance.syncFromProfile(
      userId: payload.data.userId,
      locale: payload.data.locale,
    );
    return payload;
  }

  /// Upload or replace profile photo (`POST /profiles/me/avatar`).
  Future<LearnerProfilePayload> uploadAvatar({
    required List<int> bytes,
    required String filename,
    String? mimeType,
  }) async {
    try {
      final response = await _apiClient.postMultipart(
        '/profiles/me/avatar',
        fieldName: 'file',
        bytes: bytes,
        filename: filename,
        mimeType: mimeType,
        authorized: true,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final payload = LearnerProfilePayload.fromJson(json);
        if (payload.status) {
          MediaImageLoader.clearCache();
          ApiRequestCoordinator.invalidate(pathContains: '/profiles');
          ApiRequestCoordinator.invalidate(pathContains: '/auth/me');
          await CurrentUserStorage.instance.saveUserMap(payload.data.toJson());
          await AppLanguageController.instance.syncFromProfile(
            userId: payload.data.userId,
            locale: payload.data.locale,
          );
        }
        return payload;
      }

      throw ApiException(
        response.statusCode,
        parseApiErrorBody(response.body, fallback: 'Could not upload profile photo.'),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(0, 'Unexpected error: $e');
    }
  }

  /// Update user's profile
  Future<LearnerProfilePayload> updateProfile(ProfileUpdateRequest updateData) async {
    try {
      final response = await _apiClient.patchJson(
        '/profiles',
        updateData.toJson(),
        authorized: true,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final payload = LearnerProfilePayload.fromJson(json);
        if (payload.status) {
          await CurrentUserStorage.instance.saveUserMap(payload.data.toJson());
          await AppLanguageController.instance.syncFromProfile(
      userId: payload.data.userId,
      locale: payload.data.locale,
    );
          return payload;
        }
        throw ApiException(
          response.statusCode,
          parseApiErrorBody(response.body, fallback: 'Failed to update profile.'),
        );
      } else {
        throw ApiException(
          response.statusCode,
          parseApiErrorBody(response.body, fallback: 'Failed to update profile.'),
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(0, 'Unexpected error: $e');
    }
  }
}
