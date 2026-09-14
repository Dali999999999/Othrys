import 'package:fluent_ui/fluent_ui.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dialog_sizes.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';

/// Modal dialog for creating new files, new folders, or renaming existing entries
/// with full input validation, location context, and Windows 11 Fluent UI aesthetics.
class SftpEntryNameDialog extends StatefulWidget {
  final String title;
  final String currentPath;
  final bool isDirectory;
  final bool isRename;
  final String? initialName;
  final List<String> existingNames;

  const SftpEntryNameDialog({
    super.key,
    required this.title,
    required this.currentPath,
    required this.isDirectory,
    this.isRename = false,
    this.initialName,
    this.existingNames = const [],
  });

  /// Helper to display the dialog and return the resulting validated name or null if cancelled.
  static Future<String?> show({
    required BuildContext context,
    required String title,
    required String currentPath,
    required bool isDirectory,
    bool isRename = false,
    String? initialName,
    List<String> existingNames = const [],
  }) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => SftpEntryNameDialog(
        title: title,
        currentPath: currentPath,
        isDirectory: isDirectory,
        isRename: isRename,
        initialName: initialName,
        existingNames: existingNames,
      ),
    );
  }

  @override
  State<SftpEntryNameDialog> createState() => _SftpEntryNameDialogState();
}

class _SftpEntryNameDialogState extends State<SftpEntryNameDialog> {
  late final TextEditingController _controller;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');

    // If renaming a file, select only the base name (excluding extension) for ergonomic editing
    if (widget.isRename && widget.initialName != null && widget.initialName!.isNotEmpty) {
      final name = widget.initialName!;
      if (!widget.isDirectory && name.contains('.') && !name.startsWith('.')) {
        final lastDotIndex = name.lastIndexOf('.');
        _controller.selection = TextSelection(baseOffset: 0, extentOffset: lastDotIndex);
      } else {
        _controller.selection = TextSelection(baseOffset: 0, extentOffset: name.length);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() => _validationError = null);
      return;
    }

    if (trimmed == '.' || trimmed == '..') {
      setState(() => _validationError = context.l10n.filesInvalidName);
      return;
    }

    if (trimmed.contains('/') || trimmed.contains('\\') || trimmed.contains('\u0000')) {
      setState(() => _validationError = context.l10n.filesInvalidName);
      return;
    }

    final lower = trimmed.toLowerCase();
    final isDuplicate = widget.existingNames.any(
      (n) =>
          n.toLowerCase() == lower &&
          (!widget.isRename || n.toLowerCase() != (widget.initialName?.toLowerCase() ?? '')),
    );

    if (isDuplicate) {
      setState(() => _validationError = context.l10n.filesNameAlreadyExists);
      return;
    }

    if (_validationError != null) {
      setState(() => _validationError = null);
    }
  }

  bool get _isValid {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) return false;
    if (_validationError != null) return false;
    if (trimmed == '.' || trimmed == '..') return false;
    if (trimmed.contains('/') || trimmed.contains('\\') || trimmed.contains('\u0000')) return false;
    final lower = trimmed.toLowerCase();
    if (widget.existingNames.any(
      (n) =>
          n.toLowerCase() == lower &&
          (!widget.isRename || n.toLowerCase() != (widget.initialName?.toLowerCase() ?? '')),
    )) {
      return false;
    }
    if (widget.isRename && trimmed == widget.initialName) return false;
    return true;
  }

  void _submit() {
    if (_isValid) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = widget.isRename
        ? AppColors.primaryAccent
        : (widget.isDirectory ? AppColors.brandCyan : AppColors.blueLink);

    final IconData headerIcon = widget.isRename
        ? FluentIcons.rename
        : (widget.isDirectory ? FluentIcons.new_folder : FluentIcons.page_add);

    final IconData fieldPrefixIcon = widget.isDirectory ? FluentIcons.folder : FluentIcons.page;

    final String placeholder = widget.isRename
        ? context.l10n.filesRenamePlaceholder
        : (widget.isDirectory ? context.l10n.filesFolderPlaceholder : context.l10n.filesFilePlaceholder);

    final String confirmActionLabel = widget.isRename
        ? context.l10n.filesRename
        : context.l10n.filesCreate;

    return ContentDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: AppColors.badgeBackground(accentColor),
              borderRadius: AppRadius.borderSm,
              border: Border.all(
                color: AppColors.badgeBorder(accentColor),
                width: 1,
              ),
            ),
            child: Icon(
              headerIcon,
              size: AppIconSize.md,
              color: accentColor,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              widget.title,
              style: AppTypo.titleMedium(context),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: AppDialogSize.compactWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location path context pill
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated(context),
                borderRadius: AppRadius.borderSm,
                border: Border.all(
                  color: AppColors.surfaceBorder(context),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    FluentIcons.folder_horizontal,
                    size: AppIconSize.sm,
                    color: AppColors.textMuted(context),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    context.l10n.filesLocation,
                    style: AppTypo.caption(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      widget.currentPath,
                      style: AppTypo.codeMuted(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Input field
            InfoLabel(
              label: '${context.l10n.filesNameLabel} *',
              child: TextBox(
                controller: _controller,
                placeholder: placeholder,
                autofocus: true,
                prefix: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  child: Icon(
                    fieldPrefixIcon,
                    size: AppIconSize.md,
                    color: AppColors.textMuted(context),
                  ),
                ),
                suffix: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(FluentIcons.clear, size: AppIconSize.xs),
                        onPressed: () {
                          _controller.clear();
                          _validate('');
                          setState(() {});
                        },
                      )
                    : null,
                onChanged: (val) {
                  _validate(val);
                  setState(() {});
                },
                onSubmitted: (_) => _submit(),
              ),
            ),

            if (_validationError != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                _validationError!,
                style: AppTypo.micro(context).copyWith(color: AppColors.danger),
              ),
            ],
          ],
        ),
      ),
      actions: [
        Button(
          child: Text(context.l10n.commonCancel),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        FilledButton(
          onPressed: _isValid ? _submit : null,
          child: Text(confirmActionLabel),
        ),
      ],
    );
  }
}
