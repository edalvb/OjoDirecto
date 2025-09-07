// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OjoDirecto';

  @override
  String get editScript => 'Edit script';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get scriptHint => 'Write your script here...';

  @override
  String get speedIncrease => '+ Speed';

  @override
  String get speedDecrease => '- Speed';

  @override
  String get selectFolderDialog => 'Select a folder to save';

  @override
  String get defaultScript =>
      'Place your script here. Speak naturally and keep your eyes on the camera.';
}
