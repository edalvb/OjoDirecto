import 'package:flutter/material.dart';
import 'package:ojodirecto/l10n/app_localizations.dart';
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
  late final AnimationController _scrollTicker;

  @override
  void initState() {
    super.initState();
    final s = ref.read(teleprompterStatesProvider);
    _scrollTicker =
        AnimationController(
            vsync: this,
            duration: Duration(seconds: s.scrollSpeed.toInt()),
          )
          ..addListener(_onTick)
          ..repeat();

    // Escuchar cambios de velocidad una sola vez (no dentro de build)
    ref.listen<TeleprompterStatesData>(teleprompterStatesProvider, (
      prev,
      next,
    ) {
      if (prev?.scrollSpeed != next.scrollSpeed) {
        // Ajuste suave: no resetear progreso; cambiar duration y re-sincronizar.
        final progress = _scrollTicker.value;
        final wasAnimating = _scrollTicker.isAnimating;
        _scrollTicker.stop();
        _scrollTicker.duration = Duration(seconds: next.scrollSpeed.toInt());
        if (wasAnimating && next.playing) {
          // Reanudar desde el mismo valor proporcional.
          _scrollTicker.forward(from: progress);
          _scrollTicker.repeat();
        }
      }
      if (prev?.playing != next.playing) {
        if (next.playing) {
          if (!_scrollTicker.isAnimating) {
            _scrollTicker.repeat();
          }
        } else {
          _scrollTicker.stop();
        }
      }
    });
  }

  void _onTick() {
    final store = ref.read(teleprompterStoreProvider);
    if (!store.textScrollController.hasClients) return;
    final max = store.textScrollController.position.maxScrollExtent;
    final playing = ref.read(teleprompterStatesProvider).playing;
    if (!playing) return; // no mover si está en pausa
    store.textScrollController.jumpTo(_scrollTicker.value * max);
  }

  @override
  void dispose() {
    _scrollTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(teleprompterStoreProvider);
    final data = ref.watch(teleprompterStatesProvider);
    final controller = ref.read(teleprompterControllerProvider);
    final h = MediaQuery.of(context).size.height;
    final t = AppLocalizations.of(context);
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
              color: Colors.black.withValues(alpha: 0.45),
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
                onPressed: controller.toggleScrolling,
                child: Text(data.playing ? t.pause : t.play),
              ),
              ElevatedButton(
                onPressed:
                    () => controller.updateScrollSpeed(data.scrollSpeed + 2),
                child: Text(t.speedIncrease),
              ),
              ElevatedButton(
                onPressed:
                    () => controller.updateScrollSpeed(data.scrollSpeed - 2),
                child: Text(t.speedDecrease),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
