/// Reads query parameters from Flutter web hash routes, e.g. `#/reset-password?token=abc`.
class RouteQuery {
  static Map<String, String> currentQueryParameters() {
    final fragment = Uri.base.fragment.trim();
    if (fragment.isEmpty) return const {};
    final path = fragment.startsWith('/') ? fragment : '/$fragment';
    return Uri.parse('http://local$path').queryParameters;
  }

  static String? parameter(String key) => currentQueryParameters()[key];
}
