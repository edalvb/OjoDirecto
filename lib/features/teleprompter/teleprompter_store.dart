import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeleprompterStore {
  final ScrollController textScrollController = ScrollController();
  final TextEditingController scriptController = TextEditingController();
  CameraController? cameraController;
  Future<void>? cameraInitFuture;
  List<CameraDescription> available = const [];
  bool usingRear = true;
  String folderDialogTitle = 'selectFolderDialog';
  void dispose() {
    textScrollController.dispose();
    scriptController.dispose();
    cameraController?.dispose();
  }
}

final teleprompterStoreProvider = Provider<TeleprompterStore>((ref) {
  final store = TeleprompterStore();
  ref.onDispose(store.dispose);
  return store;
});
