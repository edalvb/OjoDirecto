import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../teleprompter_store.dart';
import '../teleprompter_states.dart';
import '../teleprompter_controller.dart';

class TeleprompterLayout extends ConsumerStatefulWidget {
  const TeleprompterLayout({super.key});
  @override
  ConsumerState<TeleprompterLayout> createState() => _TeleprompterLayoutState();
}

class _TeleprompterLayoutState extends ConsumerState<TeleprompterLayout>
    with SingleTickerProviderStateMixin {
  AnimationController? scrollController;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initAnimation();
  }

  void _initAnimation() {
    scrollController?.dispose();
    final s = ref.read(teleprompterStatesProvider);
    scrollController =
        AnimationController(
            vsync: this,
            duration: Duration(seconds: s.scrollSpeed.toInt()),
          )
          ..addListener(_onTick)
          ..repeat();
  }

  void _onTick() {
    final store = ref.read(teleprompterStoreProvider);
    if (!store.textScrollController.hasClients) return;
    final max = store.textScrollController.position.maxScrollExtent;
    store.textScrollController.jumpTo(scrollController!.value * max);
  }

  @override
  void dispose() {
    scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(teleprompterStoreProvider);
    final data = ref.watch(teleprompterStatesProvider);
    ref.listen(teleprompterStatesProvider, (prev, next) {
      if (prev?.scrollSpeed != next.scrollSpeed) _initAnimation();
    });
    final controller = ref.read(teleprompterControllerProvider);
    final h = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        if (store.cameraController != null &&
            store.cameraController!.value.isInitialized)
          CameraPreview(store.cameraController!),
        Align(
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onVerticalDragUpdate:
                (d) => controller.updateAreaFactor(
                  data.areaFactor + d.delta.dy / h,
                ),
            child: Container(
              width: double.infinity,
              height: h * data.areaFactor,
              color: Colors.black.withOpacity(0.45),
              child: SingleChildScrollView(
                controller: store.textScrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    data.script,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          right: 20,
          child: Column(
            children: [
              ElevatedButton(
                onPressed:
                    () => controller.updateScrollSpeed(data.scrollSpeed - 2),
                child: const Text('+ Velocidad'),
              ),
              ElevatedButton(
                onPressed:
                    () => controller.updateScrollSpeed(data.scrollSpeed + 2),
                child: const Text('- Velocidad'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
