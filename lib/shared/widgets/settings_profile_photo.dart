import 'package:flutter/material.dart';

import '../../core/media/media_url.dart';
import '../../core/media/network_media_image.dart';
import '../constants/app_assets.dart';

/// Settings header profile photo.
///
/// Default [fallbackAsset] is a composite graphic (face + white ring + edit badge).
/// Uploaded photos use a separate circular frame so borders/buttons are not doubled.
class SettingsProfilePhoto extends StatelessWidget {
  const SettingsProfilePhoto({
    super.key,
    this.avatarUrl,
    required this.onEditTap,
    this.isUploading = false,
    this.size = 88,
    this.fallbackAsset = AppAssets.studentimage,
    this.photoFallbackAsset = AppAssets.studentAvatar,
  });

  final String? avatarUrl;
  final VoidCallback? onEditTap;
  final bool isUploading;
  final double size;
  final String fallbackAsset;
  final String photoFallbackAsset;

  static const double _borderWidth = 3;
  static const double _editTapSize = 26;

  @override
  Widget build(BuildContext context) {
    final resolved = resolveMediaUrl(avatarUrl);
    final hasUploadedPhoto =
        resolved.isNotEmpty && isNetworkMediaUrl(resolved);

    if (!hasUploadedPhoto) {
      return _placeholderAvatar();
    }
    return _uploadedAvatar(resolved);
  }

  Widget _placeholderAvatar() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Image.asset(
            fallbackAsset,
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          if (isUploading) _uploadingOverlay(),
          _editTapTarget(showBadge: false),
        ],
      ),
    );
  }

  Widget _uploadedAvatar(String url) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: _borderWidth),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: NetworkMediaImage(
                key: ValueKey(url),
                url: url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                fallback: _plainPhoto(),
              ),
            ),
          ),
          if (isUploading) _uploadingOverlay(),
          _editTapTarget(showBadge: true),
        ],
      ),
    );
  }

  Widget _plainPhoto() {
    return Image.asset(
      photoFallbackAsset,
      width: size,
      height: size,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
    );
  }

  Widget _editTapTarget({required bool showBadge}) {
    return Positioned(
      right: 0,
      bottom: 2,
      child: GestureDetector(
        onTap: isUploading ? null : onEditTap,
        behavior: HitTestBehavior.opaque,
        child: showBadge
            ? Container(
                width: _editTapSize,
                height: _editTapSize,
                decoration: const BoxDecoration(
                  color: Color(0xFFF47495),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 14,
                  color: Color(0xFF1A1C1C),
                ),
              )
            : const SizedBox(
                width: _editTapSize,
                height: _editTapSize,
              ),
      ),
    );
  }

  Widget _uploadingOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
