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
    return Scaffold(
      appBar: AppBar(
        title: Text(t.editScript),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              ref.read(teleprompterControllerProvider).saveDraftScript();
              Navigator.of(context).pop();
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(teleprompterControllerProvider).cancelDraftScript();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body:
          s.editing
              ? const TeleprompterEditorLayout()
              : const SizedBox.shrink(),
    );
  }
}
