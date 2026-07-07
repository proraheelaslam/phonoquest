import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class SettingsMenuItem {
  final String? iconImage;
  final IconData? iconData;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback? onTap;

  const SettingsMenuItem({
    this.iconImage,
    this.iconData,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.onTap,
  }) : assert(iconImage != null || iconData != null, 'Provide either iconImage or iconData for SettingsMenuItem.');
}

class SettingsMenuSection extends StatelessWidget {
  final String title;
  final List<SettingsMenuItem> items;

  const SettingsMenuSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            fontSize: 20, // 👈 increase font size
            fontWeight: FontWeight.w600,
            color: const Color.fromRGBO(26, 28, 28, 1),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  _SettingsMenuTile(item: item),
                  if (!isLast)
                    const Column(
                      children: [
                        SizedBox(height: 0),
                        Divider(
                          height: 0,
                          thickness: 1,
                          color: Color.fromRGBO(243, 243, 243, 1),
                        ),
                      ],
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingsMenuTile extends StatelessWidget {
  final SettingsMenuItem item;

  const _SettingsMenuTile({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        child: Row(
          children: [
            // ignore: avoid_unnecessary_containers
            Container(

             child: item.iconData != null
                 ? Icon(
                     item.iconData,
                     size: 25,
                     color: const Color.fromRGBO(26, 28, 28, 1),
                   )
                 : Image.asset(
                     item.iconImage!,
                     width: 25,
                     height: 25,
                     fit: BoxFit.contain,
                   ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 28 / 20, // 👈 line height (28px)
                      letterSpacing: 0,
                      color: const Color.fromRGBO(26, 28, 28, 1),
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                        item.subtitle!,
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                          color: const Color.fromRGBO(26, 28, 28, 1),
                          height: 1.2,
                        ),
                      ),
                  ],
                ],
              ),
            ),
            if (item.trailingText != null) ...[
              const SizedBox(width: 8),
             Text(
                item.trailingText!,
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w300, // Light
                  height: 1.0, // 100% line height
                  letterSpacing: 0,
                  color: const Color.fromRGBO(65, 71, 84, 1),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Color.fromRGBO(148, 163, 184, 1),
            ),
          ],
        ),
      ),
    );
  }
}
