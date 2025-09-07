import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ojodirecto/l10n/app_localizations.dart';
import '../teleprompter_states.dart';
import '../teleprompter_controller.dart';

class TeleprompterEditorLayout extends ConsumerStatefulWidget {
  const TeleprompterEditorLayout({super.key});
  @override
  ConsumerState<TeleprompterEditorLayout> createState() =>
      _TeleprompterEditorLayoutState();
}

class _TeleprompterEditorLayoutState
    extends ConsumerState<TeleprompterEditorLayout> {
  late TextEditingController controller;
  double fontSize = 20;
  @override
  void initState() {
    super.initState();
    final s = ref.read(teleprompterStatesProvider);
    controller = TextEditingController(text: s.draftScript);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    ref.listen(teleprompterStatesProvider, (p, n) {
      if (controller.text != n.draftScript) controller.text = n.draftScript;
    });
    final s = ref.watch(teleprompterStatesProvider);
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: TextStyle(fontSize: fontSize, height: 1.4),
              onChanged:
                  (v) => ref
                      .read(teleprompterControllerProvider)
                      .updateDraftScript(v),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: t.scriptHint,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.text_fields, size: 20),
              Expanded(
                child: Slider(
                  value: fontSize,
                  min: 14,
                  max: 40,
                  onChanged: (v) => setState(() => fontSize = v),
                ),
              ),
              Text(fontSize.toStringAsFixed(0)),
              const SizedBox(width: 12),
              Text(s.draftScript.length.toString()),
            ],
          ),
        ),
      ],
    );
  }
}
