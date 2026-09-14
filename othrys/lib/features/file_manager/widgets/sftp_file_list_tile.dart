import 'package:fluent_ui/fluent_ui.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/file_entry_entity.dart';
import '../../../core/utils/formatters.dart';

/// Interactive list tile representing a remote SFTP file or directory entry.
class SftpFileListTile extends StatelessWidget {
  final FileEntryEntity item;
  final VoidCallback onOpen;
  final VoidCallback onDownload;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const SftpFileListTile({
    super.key,
    required this.item,
    required this.onOpen,
    required this.onDownload,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDir = item.isDirectory;
    final sizeStr = isDir ? context.l10n.filesFolderType : Formatters.formatBytes(item.size);
    final modifiedStr = item.modifiedTime != null
        ? Formatters.formatDateTime(item.modifiedTime!)
        : '';

    return ListTile.selectable(
      leading: Icon(
        isDir ? FluentIcons.folder : FluentIcons.page,
        color: isDir ? AppColors.brandCyan : AppColors.textMuted(context),
        size: AppIconSize.lg,
      ),
      title: Text(
        item.name,
        style: AppTypo.body(context).copyWith(
          color: AppColors.textPrimary(context),
        ),
      ),
      subtitle: Text(
        '$sizeStr  •  $modifiedStr',
        style: AppTypo.micro(context).copyWith(color: AppColors.textFaint(context)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isDir)
            IconButton(
              icon: const Icon(FluentIcons.download, size: AppIconSize.md),
              onPressed: onDownload,
            ),
          IconButton(
            icon: const Icon(FluentIcons.rename, size: AppIconSize.md),
            onPressed: onRename,
          ),
          IconButton(
            icon: const Icon(FluentIcons.delete, size: AppIconSize.md, color: AppColors.danger),
            onPressed: onDelete,
          ),
        ],
      ),
      onPressed: onOpen,
    );
  }
}
