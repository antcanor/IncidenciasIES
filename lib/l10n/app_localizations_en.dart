// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get permissions => 'Permissions';

  @override
  String get camera => 'Camera';

  @override
  String get microphone => 'Microphone';

  @override
  String get request => 'Request permission';

  @override
  String get granted => 'Granted';

  @override
  String get denied => 'Not granted';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get permissionOnlyOnUse =>
      'Permissions are requested only after pressing the button.';

  @override
  String get permissionUpdated => 'Permission updated.';

  @override
  String get permissionError => 'Could not check permission.';
}
