import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'teleprompter_controller.dart';
import 'teleprompter_states.dart';
import 'widgets/teleprompter_layout.dart';
import 'teleprompter_store.dart';

class TeleprompterView extends ConsumerWidget {
  const TeleprompterView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loader = ref.watch(teleprompterLoaderProvider);
    final controller = ref.read(teleprompterControllerProvider);
    final states = ref.watch(teleprompterStatesProvider);
    final store = ref.watch(teleprompterStoreProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('OjoDirecto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editScript(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: controller.toggleCamera,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: states.recording ? Colors.red : Colors.blue,
        onPressed: controller.toggleRecording,
        child: Icon(states.recording ? Icons.stop : Icons.videocam),
      ),
      body: loader.when(
        data:
            (_) =>
                store.cameraInitFuture == null
                    ? const Center(child: CircularProgressIndicator())
                    : FutureBuilder<void>(
                      future: store.cameraInitFuture,
                      builder: (c, snap) {
                        if (snap.connectionState == ConnectionState.done &&
                            store.cameraController?.value.isInitialized ==
                                true) {
                          return const TeleprompterLayout();
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
        error: (e, st) => Center(child: Text('$e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _editScript(BuildContext context, WidgetRef ref) {
    final current = ref.read(teleprompterStatesProvider).script;
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder:
          (c) => AlertDialog(
            title: const Text('Editar guion'),
            content: TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Escribe tu guion aquí...',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref
                      .read(teleprompterControllerProvider)
                      .updateScript(controller.text);
                  Navigator.pop(c);
                },
                child: const Text('Guardar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Cancelar'),
              ),
            ],
          ),
    );
  }
}
