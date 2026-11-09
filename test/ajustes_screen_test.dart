import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidencias_ies/settings/settings.dart';
import 'package:incidencias_ies/screens/ajustes_screen.dart';
import 'package:incidencias_ies/theme/theme.dart';

void main() {
  testWidgets('Ajustes aplica idioma y tema inmediatamente', (tester) async {
    final themeController = ThemeController();
    final localeController = LocaleController();

    await tester.pumpWidget(
      ListenableBuilder(
        listenable: Listenable.merge([themeController, localeController]),
        builder: (context, _) => MaterialApp(
          locale: localeController.locale,
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          home: AjustesScreen(
            themeController: themeController,
            localeController: localeController,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ajustes'), findsOneWidget);
    await tester.tap(find.text('Inglés'));
    await tester.pumpAndSettle();
    expect(localeController.isEnglish, isTrue);
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(themeController.isDarkMode, isTrue);
  });
}
