class DashboardModule {
  final String title;
  final String subtitle;
  final String route;
  final String icon;

  const DashboardModule({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
  });
}

class SoundTileModel {
  final String label;
  final String hint;
  final String example;

  const SoundTileModel({required this.label, required this.hint, required this.example});
}
