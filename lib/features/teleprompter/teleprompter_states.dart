import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeleprompterStatesData {
  final bool recording;
  final double scrollSpeed;
  final double areaFactor;
  final String script;
  TeleprompterStatesData({
    required this.recording,
    required this.scrollSpeed,
    required this.areaFactor,
    required this.script,
  });
  TeleprompterStatesData copyWith({
    bool? recording,
    double? scrollSpeed,
    double? areaFactor,
    String? script,
  }) => TeleprompterStatesData(
    recording: recording ?? this.recording,
    scrollSpeed: scrollSpeed ?? this.scrollSpeed,
    areaFactor: areaFactor ?? this.areaFactor,
    script: script ?? this.script,
  );
}

class TeleprompterStates extends StateNotifier<TeleprompterStatesData> {
  TeleprompterStates()
    : super(
        TeleprompterStatesData(
          recording: false,
          scrollSpeed: 20,
          areaFactor: 0.2,
          script:
              'Aquí va tu guion. Habla con naturalidad y mantén la mirada en la cámara.',
        ),
      );
  void setRecording(bool v) => state = state.copyWith(recording: v);
  void setScrollSpeed(double v) => state = state.copyWith(scrollSpeed: v);
  void setAreaFactor(double v) => state = state.copyWith(areaFactor: v);
  void setScript(String v) => state = state.copyWith(script: v);
}

final teleprompterStatesProvider =
    StateNotifierProvider<TeleprompterStates, TeleprompterStatesData>((ref) {
      return TeleprompterStates();
    });
