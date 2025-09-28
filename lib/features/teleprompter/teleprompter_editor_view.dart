import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojodirecto/l10n/app_localizations.dart';
import 'teleprompter_states.dart';
import 'teleprompter_controller.dart';
import 'widgets/teleprompter_editor_layout.dart';

class TeleprompterEditorView extends ConsumerWidget {
  const TeleprompterEditorView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final s = ref.watch(teleprompterStatesProvider);
    final controller = ref.read(teleprompterControllerProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        controller.finishScriptEditing();
        Navigator.of(context).pop(result);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.editScript),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).maybePop();
              },
            ),
          ],
        ),
        body:
            s.editing
                ? const TeleprompterEditorLayout()
                : const SizedBox.shrink(),
      ),
    );
  }
}
