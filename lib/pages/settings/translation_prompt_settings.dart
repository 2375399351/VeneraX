part of 'settings_page.dart';

/// Editor for the translation system prompt. Users shorten it to cut the tokens
/// every request spends, or reword it to change how the model translates; Reset
/// puts the built-in text back.
class TranslationPromptPage extends StatefulWidget {
  const TranslationPromptPage({super.key});

  @override
  State<TranslationPromptPage> createState() => _TranslationPromptPageState();
}

class _TranslationPromptPageState extends State<TranslationPromptPage> {
  late final TextEditingController _controller;

  /// What was on disk when the page opened, to tell an edit from a no-op.
  late final String _initial;

  @override
  void initState() {
    super.initState();
    _initial = LlmPromptStore.template;
    _controller = TextEditingController(text: _initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _changed => _controller.text.trim() != _initial.trim();

  bool get _isBlank => _controller.text.trim().isEmpty;

  void _save() {
    LlmPromptStore.save(_controller.text);
    if (!mounted) return;
    context.showMessage(message: "Translation prompt saved".tl);
    context.pop();
  }

  /// Puts the built-in text in the field without persisting: like any other
  /// edit here, it only takes effect on Save, so Cancel still backs out.
  void _reset() {
    showConfirmDialog(
      context: App.rootContext,
      title: "Reset".tl,
      content: "Restore the built-in translation prompt?".tl,
      onConfirm: () =>
          setState(() => _controller.text = LlmPromptStore.builtIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbar(
        title: Text("Translation prompt".tl),
        actions: [TextButton(onPressed: _reset, child: Text("Reset".tl))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              "Sent to the AI model with every request. Shorten it to spend fewer tokens, at the cost of translation quality and consistent character names. Keep \$target where the target language should appear."
                  .tl,
              style: ts.s14.copyWith(color: context.colorScheme.outline),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: context.colorScheme.outlineVariant),
              ),
              child: TextField(
                controller: _controller,
                expands: true,
                maxLines: null,
                minLines: null,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                style: ts.s14,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Translation prompt".tl,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          if (!_isBlank &&
              !LlmPromptStore.hasTargetPlaceholder(_controller.text))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: context.colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Without \$target the model is not told which language to translate into."
                          .tl,
                      style: ts.s12.copyWith(color: context.colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + context.padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    child: Text("Cancel".tl),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _changed ? _save : null,
                    child: Text("Save".tl),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
