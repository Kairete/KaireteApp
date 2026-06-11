/// Identificativo build visibile in app (aggiornare ad ogni release).
class AppBuild {
  AppBuild._();

	static const label = 'fix33';
	static const stamp = '20250607n';

  /// Titolo barra home: etichetta + timbro per capire subito quale APK è installato.
  static String get appBarTitle => 'Kairete · $label · $stamp';
}
