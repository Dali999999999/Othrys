import 'package:fluent_ui/fluent_ui.dart';
import '../../../app/theme/app_dialog_sizes.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';

/// Modal dialog for editing and saving remote file text content.
class SftpFileEditorDialog extends StatefulWidget {
  final String fileName;
  final String initialContent;

  const SftpFileEditorDialog({
    super.key,
    required this.fileName,
    required this.initialContent,
  });

  @override
  State<SftpFileEditorDialog> createState() => _SftpFileEditorDialogState();
}

class _SftpFileEditorDialogState extends State<SftpFileEditorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(context.l10n.filesEditorTitle(widget.fileName)),
      content: SizedBox(
        width: AppDialogSize.wideWidth,
        height: AppDialogSize.wideHeight,
        child: TextBox(
          controller: _controller,
          maxLines: null,
          style: AppTypo.code(context),
        ),
      ),
      actions: [
        Button(
          child: Text(context.l10n.commonCancel),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        FilledButton(
          child: Text(context.l10n.filesSaveFile),
          onPressed: () => Navigator.of(context).pop(_controller.text),
        ),
      ],
    );
  }
}
