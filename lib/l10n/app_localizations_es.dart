// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'OjoDirecto';

  @override
  String get editScript => 'Editar guion';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get scriptHint => 'Escribe tu guion aquí...';

  @override
  String get speedIncrease => '+ Velocidad';

  @override
  String get speedDecrease => '- Velocidad';

  @override
  String get selectFolderDialog => 'Selecciona la carpeta para guardar';

  @override
  String get defaultScript =>
      'Aquí va tu guion. Habla con naturalidad y mantén la mirada en la cámara.';
}
