import 'app_locale.dart';
import 'app_translation_maps.dart';

class AppTranslations {
  AppTranslations(this.localeCode);

  final String localeCode;

  bool get isSpanish => AppLocale.normalize(localeCode) == AppLocale.es;

  String get localeCodeNormalized => AppLocale.normalize(localeCode);

  /// Lookup English literal → Spanish (or return original for English).
  String tr(String english) {
    if (!isSpanish || english.isEmpty) return english;
    return AppTranslationMaps.es[english] ?? english;
  }

  String get languageScreenTitle => isSpanish ? 'Idioma' : 'Language';
  String get chooseAppLanguage => tr('Choose App Language');
  String get chooseAppLanguageHint =>
      tr('Select your preferred language for the app interface.');
  String get saveLanguage => isSpanish ? 'GUARDAR IDIOMA' : 'SAVE LANGUAGE';
  String get savingLanguage => tr('SAVING...');
  String get languageUpdated => isSpanish
      ? 'Idioma actualizado. La interfaz se aplicará en toda la app.'
      : 'Language updated. The interface will apply across the app.';

  String get settingsTitle => tr('Settings');
  String get accountSection => isSpanish ? 'Cuenta' : 'Account';
  String get appSettingsSection => isSpanish ? 'Ajustes de la app' : 'App Settings';
  String get supportSection => isSpanish ? 'Soporte' : 'Support';

  String get accountDetails => tr('Account Details');
  String get accountDetailsSubtitle => tr('Edit your profile and photos');
  String get changePassword => tr('Change Password');
  String get changePasswordSubtitle => tr('Change your password');
  String get subscription => tr('Subscription');
  String get subscriptionFamilySubtitle => tr('Manage your family plan');
  String get subscriptionViewSubtitle => tr('View your family plan access');

  String get languageMenuTitle => isSpanish ? 'Idioma' : 'Language';
  String get languageMenuSubtitle => isSpanish
      ? 'Los cambios se aplicarán solo a tu cuenta.'
      : 'Changes apply only to your account.';
  String get soundAudio => isSpanish ? 'Sonido y audio' : 'Sound & Audio';
  String get accessibility => tr('Accessibility');
  String get accessibilitySubtitle => tr('Theme, Font size, contrast, reading aids');

  String get inviteFriend => tr('Invite Friend');
  String get giveFeedback => tr('Give Feedback');
  String get giveFeedbackSubtitle => tr('Give feedback to improve app');
  String get helpSupport => tr('Help & support');
  String get helpSupportSubtitle => tr('Learning, Login, verification, others');
  String get termsPrivacy => tr('Terms & Privacy Policy');
  String get appVersion => tr('App Version');
  String get logout => tr('Logout');

  String get navHome => tr('Home');
  String get navJourney => tr('Journey');
  String get navProgress => tr('Progress');
  String get navSettings => tr('Settings');
  String get navDashboard => tr('Dashboard');
  String get navClasses => tr('Classes');
  String get navMessages => isSpanish ? 'Mensajes' : 'Messages';
  String get navReports => tr('Reports');
  String get navResources => isSpanish ? 'Recursos' : 'Resources';
  String get navStatus => isSpanish ? 'Estado' : 'Status';

  String get accountLanguageLabel => isSpanish ? 'Idioma' : 'Language';
  String get profileUpdated =>
      isSpanish ? '¡Perfil actualizado!' : 'Profile updated successfully!';
  String get couldNotUpdateLanguage =>
      isSpanish ? 'No se pudo actualizar el idioma.' : 'Could not update language.';
  String get signInRequired => isSpanish
      ? 'Inicia sesión para guardar tu idioma.'
      : 'Sign in to save your language preference.';
  String get perUserLanguageNote => isSpanish
      ? 'El idioma se guarda solo para tu cuenta. Otros usuarios en este dispositivo conservan su propia preferencia.'
      : 'Language is saved for your account only. Other users on this device keep their own preference.';
}
