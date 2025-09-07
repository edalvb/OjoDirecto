import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppThemeStateData {
  final ThemeMode mode;
  final bool useDynamic;
  AppThemeStateData({required this.mode, required this.useDynamic});
  AppThemeStateData copyWith({ThemeMode? mode, bool? useDynamic}) =>
      AppThemeStateData(
        mode: mode ?? this.mode,
        useDynamic: useDynamic ?? this.useDynamic,
      );
}

class AppThemeStates extends StateNotifier<AppThemeStateData> {
  AppThemeStates()
    : super(AppThemeStateData(mode: ThemeMode.dark, useDynamic: true));
  void toggleMode() =>
      state = state.copyWith(
        mode: state.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
      );
  void toggleDynamic() => state = state.copyWith(useDynamic: !state.useDynamic);
}

final appThemeStatesProvider =
    StateNotifierProvider<AppThemeStates, AppThemeStateData>(
      (ref) => AppThemeStates(),
    );
