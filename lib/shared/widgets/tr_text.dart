import 'package:flutter/material.dart';

import '../../core/l10n/app_language_controller.dart';

/// Drop-in [Text] that translates a static English literal for the active user.
class TrText extends StatelessWidget {
  const TrText(
    this.english, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  final String english;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    return Text(
      context.tr(english),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
