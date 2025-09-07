import 'package:flutter/material.dart';
import 'package:ojodirecto/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'teleprompter_controller.dart';
import 'teleprompter_states.dart';
import 'widgets/teleprompter_layout.dart';
import '../../app/app_theme_states.dart';
import 'teleprompter_store.dart';
import 'teleprompter_editor_view.dart';

class TeleprompterView extends ConsumerWidget {
  const TeleprompterView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loader = ref.watch(teleprompterLoaderProvider);
    final controller = ref.read(teleprompterControllerProvider);
    final states = ref.watch(teleprompterStatesProvider);
    final store = ref.watch(teleprompterStoreProvider);
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed:
                () => ref.read(appThemeStatesProvider.notifier).toggleMode(),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _openEditor(context, ref),
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

  void _openEditor(BuildContext context, WidgetRef ref) {
    ref.read(teleprompterControllerProvider).startScriptEditing();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TeleprompterEditorView()),
    );
  }
}
