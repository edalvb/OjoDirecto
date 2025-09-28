import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'teleprompter_store.dart';
import 'teleprompter_states.dart';
import '../../main.dart';

class TeleprompterController {
  final Ref ref;
  TeleprompterController(this.ref);

  Future<void> initialize() async {
    final store = ref.read(teleprompterStoreProvider);
    store.available = await ref.read(camerasProvider.future);
    final selected = _currentCameraDescription(store);
    store.cameraController = CameraController(selected, ResolutionPreset.max);
    store.cameraInitFuture = store.cameraController!.initialize();
  }

  CameraDescription _currentCameraDescription(TeleprompterStore store) {
    if (store.available.isEmpty) {
      throw StateError('No cameras available');
    }

    bool matchesDesiredLens(CameraDescription camera) {
      final lens = camera.lensDirection;
      if (lens == CameraLensDirection.external) {
        return true;
      }
      return store.usingRear
          ? lens == CameraLensDirection.back
          : lens == CameraLensDirection.front;
    }

    final matching = store.available.firstWhere(
      matchesDesiredLens,
      orElse: () => store.available.first,
    );

    // Sync the desired state with the actual camera we could obtain.
    if (matching.lensDirection == CameraLensDirection.back) {
      store.usingRear = true;
    } else if (matching.lensDirection == CameraLensDirection.front) {
      store.usingRear = false;
    }

    return matching;
  }

  Future<void> toggleCamera() async {
    final store = ref.read(teleprompterStoreProvider);
    if (store.available.length <= 1) {
      return;
    }
    store.usingRear = !store.usingRear;
    await store.cameraController?.dispose();
    final selected = _currentCameraDescription(store);
    store.cameraController = CameraController(selected, ResolutionPreset.max);
    store.cameraInitFuture = store.cameraController!.initialize();
  }

  void updateScrollSpeed(double value) {
    final s = ref.read(teleprompterStatesProvider.notifier);
    s.setScrollSpeed(value.clamp(5, 60));
  }

  void updateAreaFactor(double factor) {
    final s = ref.read(teleprompterStatesProvider.notifier);
    s.setAreaFactor(factor.clamp(0.1, 0.5));
  }

  void updateScript(String script) {
    ref.read(teleprompterStatesProvider.notifier).setScript(script);
  }

  void startScriptEditing() {
    ref.read(teleprompterStatesProvider.notifier).beginEditing();
  }

  void updateDraftScript(String value) {
    ref.read(teleprompterStatesProvider.notifier).setDraftScript(value);
  }

  void saveDraftScript() {
    ref.read(teleprompterStatesProvider.notifier).commitDraft();
  }

  void cancelDraftScript() {
    finishScriptEditing();
  }

  void finishScriptEditing() {
    ref.read(teleprompterStatesProvider.notifier).endEditing();
  }

  void pauseScrolling() {
    ref.read(teleprompterStatesProvider.notifier).setPlaying(false);
  }

  void resumeScrolling() {
    ref.read(teleprompterStatesProvider.notifier).setPlaying(true);
  }

  void toggleScrolling() {
    final s = ref.read(teleprompterStatesProvider);
    ref.read(teleprompterStatesProvider.notifier).setPlaying(!s.playing);
  }

  Future<void> toggleRecording() async {
    final store = ref.read(teleprompterStoreProvider);
    if (store.cameraController == null ||
        !store.cameraController!.value.isInitialized) {
      return;
    }
    if (store.cameraController!.value.isRecordingVideo) {
      await _saveVideo();
    } else {
      await store.cameraController!.startVideoRecording();
      ref.read(teleprompterStatesProvider.notifier).setRecording(true);
    }
  }

  Future<void> _saveVideo() async {
    final store = ref.read(teleprompterStoreProvider);
    try {
      final file = await store.cameraController!.stopVideoRecording();
      ref.read(teleprompterStatesProvider.notifier).setRecording(false);
      final dir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: store.folderDialogTitle,
      );
      if (dir != null) {
        final path = '$dir/${DateTime.now().millisecondsSinceEpoch}.mp4';
        await file.saveTo(path);
        OpenFile.open(path);
      }
    } catch (_) {}
  }
}

final teleprompterControllerProvider = Provider<TeleprompterController>((ref) {
  return TeleprompterController(ref);
});

final teleprompterLoaderProvider = FutureProvider<void>((ref) async {
  final controller = ref.read(teleprompterControllerProvider);
  await controller.initialize();
});
