import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/teleprompter/teleprompter_view.dart';
import 'app_theme.dart';
import 'app_theme_states.dart';

class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(appThemeStatesProvider);
    return MaterialApp(
      title: 'OjoDirecto',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeState.mode,
      home: const TeleprompterView(),
    );
  }
}
