import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_exception.dart';
import '../data/models/learner_profile.dart';
import '../data/repositories/profile_repository.dart';
import '../domain/profile_image_upload.dart';
import '../../../core/l10n/app_language_controller.dart';

/// Picks an image from the gallery and uploads it as the user's profile photo.
/// Returns the updated profile when upload succeeds (includes [LearnerProfile.avatar]).
Future<LearnerProfile?> pickAndUploadProfilePhoto({
  required BuildContext context,
  required ProfileRepository repository,
}) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 92,
  );
  if (picked == null) return null;

  try {
    final bytes = await picked.readAsBytes();
    final prepared = prepareProfileImageUpload(
      bytes: bytes,
      originalName: picked.name,
      pickedMimeType: picked.mimeType,
    );
    final payload = await repository.uploadAvatar(
      bytes: prepared.bytes,
      filename: prepared.filename,
      mimeType: prepared.mimeType,
    );

    if (!context.mounted) return null;

    if (payload.status) {
      final avatar = payload.data.avatar?.trim() ?? '';
      if (avatar.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('Photo saved but could not load preview. Pull to refresh.'),
            ),
            backgroundColor: Colors.orange.shade800,
          ),
        );
        return payload.data;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Profile photo updated.')),
          backgroundColor: const Color.fromRGBO(16, 185, 129, 1),
        ),
      );
      return payload.data;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          payload.message.isNotEmpty ? payload.message : 'Could not update profile photo.',
        ),
        backgroundColor: Colors.red.shade800,
      ),
    );
    return null;
  } on ApiException catch (e) {
    if (!context.mounted) return null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade800),
    );
    return null;
  } catch (_) {
    if (!context.mounted) return null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('Could not upload photo. Please try again.')),
        backgroundColor: Colors.red.shade800,
      ),
    );
    return null;
  }
}
