import 'package:flutter/material.dart';

import '../../core/l10n/app_language_controller.dart';
import '../../core/router/app_router.dart';
import '../../core/navigation/student_journey_refresh.dart';
import '../../shared/constants/app_assets.dart';
import '../../shared/widgets/primary_card.dart';
import '../dashboard/data/student_home_models.dart';
import '../dashboard/data/student_module_routes.dart';

String adventureImageAsset(String code) {
  switch (code) {
    case 'blend_forest':
      return AppAssets.journeyimage;
    case 'vowel_learning':
      return AppAssets.vowelsimage;
    case 'interactive_smart_chart':
      return AppAssets.smartchartimage;
    case 'sound_learning':
      return AppAssets.soundlearningimage;
    case 'listen_tap':
      return AppAssets.soundlistenimage;
    case 'phonics_cards':
      return AppAssets.phonicsimage;
    case 'practice':
      return AppAssets.practiceimage;
    default:
      return AppAssets.exploreimage;
  }
}

void onAdventureModuleTap(BuildContext context, AdventureModule module) {
  if (module.isLocked) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${module.title}${context.tr(' is locked')}'),
        content: Text(
          module.lockReason ??
              context.tr('Upgrade your plan or reading pace in Settings to unlock this adventure.'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.tr('Not now'))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final route = module.upgradeAction == 'subscription'
                  ? AppRouter.subscription
                  : AppRouter.studentPace;
              Navigator.pushNamed(context, route);
            },
            child: Text(
              module.upgradeLabel ??
                  (module.upgradeAction == 'subscription'
                      ? context.tr('View family plan')
                      : context.tr('Change pace')),
            ),
          ),
        ],
      ),
    );
    return;
  }
  Navigator.pushNamed(context, studentModuleRoute(module.route))
      .then((_) => StudentJourneyRefresh.notify());
}

Widget buildAdventureModuleCard(
  BuildContext context, {
  required AdventureModule module,
}) {
  final textTheme = Theme.of(context).textTheme;
  final locked = module.isLocked;
  final image = adventureImageAsset(module.code);

  return PrimaryCard(
    color: locked ? const Color(0xFFF3F4F6) : Colors.white,
    onTap: () => onAdventureModuleTap(context, module),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 72,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: locked ? 0.45 : 1,
                  child: Image.asset(image, width: 50, height: 50, fit: BoxFit.contain),
                ),
                if (locked) const Icon(Icons.lock_rounded, color: Color(0xFF6B7280)),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          module.title,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: locked ? const Color(0xFF9CA3AF) : null,
          ),
        ),
        SizedBox(height: 4),
        Text(
          module.description,
          style: textTheme.bodySmall?.copyWith(color: locked ? const Color(0xFF9CA3AF) : null),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            locked
                ? '${module.upgradeLabel ?? context.tr('Upgrade')}  ->'
                : '${context.tr('Explore')}  ->',
            style: textTheme.labelLarge?.copyWith(
              color: locked ? const Color(0xFFFF3B93) : const Color.fromRGBO(36, 88, 181, 1),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

List<Widget> buildAdventureModuleGrid(BuildContext context, List<AdventureModule> modules) {
  final rows = <Widget>[];
  for (var i = 0; i < modules.length; i += 2) {
    if (i > 0) rows.add(SizedBox(height: 10));
    final left = modules[i];
    final right = i + 1 < modules.length ? modules[i + 1] : null;
    rows.add(
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: buildAdventureModuleCard(context, module: left)),
          SizedBox(width: 12),
          Expanded(
            child: right == null
                ? const SizedBox.shrink()
                : buildAdventureModuleCard(context, module: right),
          ),
        ],
      ),
    );
  }
  return rows;
}
