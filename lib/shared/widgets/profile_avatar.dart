import 'package:flutter/material.dart';

import '../../core/media/media_image_loader.dart';
import '../../core/media/media_url.dart';
import '../constants/app_assets.dart';

/// Circular profile photo with network URL or role-based placeholder asset.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    required this.fallbackAsset,
    this.size = 80,
    this.showEditBadge = false,
    /// When true, no overlay icon — tap the asset's built-in edit badge (bottom-right).
    this.useBuiltinEditIcon = true,
    this.onTap,
  });

  final String? avatarUrl;
  final String fallbackAsset;
  final double size;
  final bool showEditBadge;
  final bool useBuiltinEditIcon;
  final VoidCallback? onTap;

  static const double _borderWidth = 3;
  static const double _editTapSize = 26;

  @override
  Widget build(BuildContext context) {
    final resolved = resolveMediaUrl(avatarUrl);
    final hasNetwork =
        resolved.isNotEmpty && isNetworkMediaUrl(resolved);

    final Widget avatar = hasNetwork
        ? _networkAvatar(resolved)
        : _placeholderAvatar();

    if (showEditBadge) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: useBuiltinEditIcon ? 4 : 0,
            bottom: useBuiltinEditIcon ? 6 : 0,
            child: useBuiltinEditIcon
                ? GestureDetector(
                    onTap: onTap,
                    behavior: HitTestBehavior.opaque,
                    child: const SizedBox(
                      width: _editTapSize,
                      height: _editTapSize,
                    ),
                  )
                : GestureDetector(
                    onTap: onTap,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(83, 200, 193, 1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }

  Widget _placeholderAvatar() {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        fallbackAsset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  Widget _networkAvatar(String url) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: _borderWidth),
      ),
      child: ClipOval(
        child: _CachedNetworkAvatarImage(
          key: ValueKey(url),
          url: url,
          fallbackAsset: _plainPhotoAsset(),
          size: size,
        ),
      ),
    );
  }

  String _plainPhotoAsset() {
    if (fallbackAsset == AppAssets.teacherprofileimage) {
      return AppAssets.profileimage;
    }
    return AppAssets.studentAvatar;
  }

  static String fallbackForRole(String? roleName, {bool parentShell = false}) {
    final role = (roleName ?? '').toLowerCase();
    if (parentShell || role == 'parent') {
      return AppAssets.studentimage;
    }
    if (role == 'teacher') {
      return AppAssets.teacherprofileimage;
    }
    return AppAssets.studentimage;
  }
}

class _CachedNetworkAvatarImage extends StatefulWidget {
  const _CachedNetworkAvatarImage({
    super.key,
    required this.url,
    required this.fallbackAsset,
    required this.size,
  });

  final String url;
  final String fallbackAsset;
  final double size;

  @override
  State<_CachedNetworkAvatarImage> createState() =>
      _CachedNetworkAvatarImageState();
}

class _CachedNetworkAvatarImageState extends State<_CachedNetworkAvatarImage> {
  ImageProvider? _provider;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _CachedNetworkAvatarImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (resolveMediaUrl(oldWidget.url) != resolveMediaUrl(widget.url)) {
      _load();
    }
  }

  Future<void> _load() async {
    final resolved = resolveMediaUrl(widget.url);
    final bytes = await MediaImageLoader.loadBytes(resolved);
    if (!mounted) return;
    setState(() {
      _provider = bytes != null && bytes.isNotEmpty ? MemoryImage(bytes) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_provider != null) {
      return Image(
        image: _provider!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _fallbackImage(),
      );
    }
    return _fallbackImage();
  }

  Widget _fallbackImage() {
    return Image.asset(
      widget.fallbackAsset,
      fit: BoxFit.cover,
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
    );
  }
}
