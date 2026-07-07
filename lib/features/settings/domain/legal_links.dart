/// Web URLs for legal documents — update here or via --dart-define at build time.
abstract final class LegalLinks {
  static const String termsUrl = String.fromEnvironment(
    'TERMS_URL',
    defaultValue: 'https://api.schoolhouse.cloud/terms-and-conditions',
  );
  static const String privacyUrl = String.fromEnvironment(
    'PRIVACY_URL',
    defaultValue: 'https://api.schoolhouse.cloud/privacy-policy',
  );
}

class LegalPolicyItem {
  const LegalPolicyItem({
    required this.titleKey,
    required this.url,
  });

  final String titleKey;
  final String url;
}

const legalPolicyMenuItems = <LegalPolicyItem>[
  LegalPolicyItem(
    titleKey: 'Terms & conditions',
    url: LegalLinks.termsUrl,
  ),
  LegalPolicyItem(
    titleKey: 'Privacy policy',
    url: LegalLinks.privacyUrl,
  ),
];
