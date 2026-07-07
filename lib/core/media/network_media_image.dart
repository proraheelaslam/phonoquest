import 'package:flutter/material.dart';

import 'media_image_loader.dart';
import 'media_url.dart';

/// Loads remote lesson media on web and mobile (handles CORS via API proxy).
class NetworkMediaImage extends StatefulWidget {
  const NetworkMediaImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallback,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? fallback;

  @override
  State<NetworkMediaImage> createState() => _NetworkMediaImageState();
}

class _NetworkMediaImageState extends State<NetworkMediaImage> {
  ImageProvider? _provider;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant NetworkMediaImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (resolveMediaUrl(oldWidget.url) != resolveMediaUrl(widget.url)) {
      _load();
    }
  }

  Future<void> _load() async {
    final resolved = resolveMediaUrl(widget.url);
    if (resolved.isEmpty) {
      if (mounted) setState(() => _failed = true);
      return;
    }

    setState(() {
      _failed = false;
      _provider = null;
    });

    final bytes = await MediaImageLoader.loadBytes(resolved);
    if (!mounted) return;

    if (bytes != null && bytes.isNotEmpty) {
      setState(() {
        _provider = MemoryImage(bytes);
        _failed = false;
      });
      return;
    }

    setState(() {
      _provider = null;
      _failed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_provider != null) {
      child = Image(
        image: _provider!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _errorPlaceholder(),
      );
    } else if (_failed) {
      child = _errorPlaceholder();
    } else {
      child = SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (widget.borderRadius != null) {
      child = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: child,
      );
    }

    return child;
  }

  Widget _errorPlaceholder() {
    if (widget.fallback != null) {
      return widget.fallback!;
    }
    return Container(
      width: widget.width,
      height: widget.height,
      color: const Color(0xFFF2F4F7),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: (widget.width ?? 24) * 0.55,
        color: const Color(0xFF98A2B3),
      ),
    );
  }
}
