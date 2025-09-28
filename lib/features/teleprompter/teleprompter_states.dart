import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeleprompterStatesData {
  final bool recording;
  final double scrollSpeed;
  final double areaFactor;
  final String script;
  final String draftScript;
  final bool editing;
  final bool playing; // nuevo: indica si el scroll está activo
  TeleprompterStatesData({
    required this.recording,
    required this.scrollSpeed,
    required this.areaFactor,
    required this.script,
    required this.draftScript,
    required this.editing,
    required this.playing,
  });
  TeleprompterStatesData copyWith({
    bool? recording,
    double? scrollSpeed,
    double? areaFactor,
    String? script,
    String? draftScript,
    bool? editing,
    bool? playing,
  }) => TeleprompterStatesData(
    recording: recording ?? this.recording,
    scrollSpeed: scrollSpeed ?? this.scrollSpeed,
    areaFactor: areaFactor ?? this.areaFactor,
    script: script ?? this.script,
    draftScript: draftScript ?? this.draftScript,
    editing: editing ?? this.editing,
    playing: playing ?? this.playing,
  );
}

class TeleprompterStates extends StateNotifier<TeleprompterStatesData> {
  TeleprompterStates()
    : super(
        TeleprompterStatesData(
          recording: false,
          scrollSpeed: 20,
          areaFactor: 0.2,
          script: 'defaultScript',
          draftScript: 'defaultScript',
          editing: false,
          playing: true,
        ),
      );
  void setRecording(bool v) => state = state.copyWith(recording: v);
  void setScrollSpeed(double v) => state = state.copyWith(scrollSpeed: v);
  void setAreaFactor(double v) => state = state.copyWith(areaFactor: v);
  void setScript(String v) => state = state.copyWith(script: v);
  void beginEditing() =>
      state = state.copyWith(draftScript: state.script, editing: true);
  void setDraftScript(String v) =>
    state = state.copyWith(draftScript: v, script: v);
  void commitDraft() =>
      state = state.copyWith(script: state.draftScript, editing: false);
  void discardDraft() =>
      state = state.copyWith(draftScript: state.script, editing: false);
  void setPlaying(bool v) => state = state.copyWith(playing: v);
  void endEditing() => state = state.copyWith(editing: false);
}

final teleprompterStatesProvider =
    StateNotifierProvider<TeleprompterStates, TeleprompterStatesData>((ref) {
      return TeleprompterStates();
    });
