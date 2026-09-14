import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/tunnel_entity.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../../servers/server_controller.dart';

/// Single-responsibility widget managing encrypted JSON backup export and import.
class BackupRestoreCard extends ConsumerStatefulWidget {
  const BackupRestoreCard({super.key});

  @override
  ConsumerState<BackupRestoreCard> createState() => _BackupRestoreCardState();
}

class _BackupRestoreCardState extends ConsumerState<BackupRestoreCard> {
  bool _isExporting = false;
  bool _isImporting = false;

  Future<void> _exportBackup() async {
    setState(() => _isExporting = true);
    try {
      final serverRepo = ref.read(serverRepositoryProvider);
      final tunnelRepo = ref.read(tunnelRepositoryProvider);

      final serversRes = await serverRepo.loadAll();
      final tunnelsRes = await tunnelRepo.loadAll();

      final servers = serversRes.getOrElse(() => []);
      final tunnels = tunnelsRes.getOrElse(() => []);

      final backupData = {
        'version': '1.0.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'servers': servers.map((s) => s.toJson()).toList(),
        'tunnels': tunnels.map((t) => t.toJson()).toList(),
      };

      final jsonStr = const JsonEncoder.withIndent('  ').convert(backupData);

      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Backup',
        fileName: 'othrys_backup.json',
      );

      if (savePath != null) {
        await File(savePath).writeAsString(jsonStr, encoding: utf8);
        if (mounted) {
          displayInfoBar(context, builder: (ctx, close) {
            return InfoBar(
              title: Text(context.l10n.commonSuccess),
              content: Text(context.l10n.settingsExportSuccess),
              severity: InfoBarSeverity.success,
              onClose: close,
            );
          });
        }
      }
    } catch (e, st) {
      AppLogger.instance.error('BackupRestoreCard', 'Export failed: $e', e, st);
      if (mounted) {
        displayInfoBar(context, builder: (ctx, close) {
          return InfoBar(
            title: Text(context.l10n.commonError),
            content: Text(e.toString()),
            severity: InfoBarSeverity.error,
            onClose: close,
          );
        });
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _importBackup() async {
    setState(() => _isImporting = true);
    try {
      final pickRes = await FilePicker.platform.pickFiles(allowMultiple: false);
      if (pickRes == null || pickRes.files.isEmpty || pickRes.files.first.path == null) {
        setState(() => _isImporting = false);
        return;
      }

      final file = File(pickRes.files.first.path!);
      final content = await file.readAsString(encoding: utf8);
      final dynamic decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid backup file structure.');
      }

      final serverRepo = ref.read(serverRepositoryProvider);
      final tunnelRepo = ref.read(tunnelRepositoryProvider);

      if (decoded['servers'] is List) {
        for (final item in decoded['servers']) {
          if (item is Map<String, dynamic>) {
            await serverRepo.save(ServerEntity.fromJson(item));
          }
        }
      }

      if (decoded['tunnels'] is List) {
        for (final item in decoded['tunnels']) {
          if (item is Map<String, dynamic>) {
            await tunnelRepo.save(TunnelEntity.fromJson(item));
          }
        }
      }

      await ref.read(serverControllerProvider.notifier).loadServers();

      if (mounted) {
        displayInfoBar(context, builder: (ctx, close) {
          return InfoBar(
            title: Text(context.l10n.commonSuccess),
            content: Text(context.l10n.settingsImportSuccess),
            severity: InfoBarSeverity.success,
            onClose: close,
          );
        });
      }
    } catch (e, st) {
      AppLogger.instance.error('BackupRestoreCard', 'Import failed: $e', e, st);
      if (mounted) {
        displayInfoBar(context, builder: (ctx, close) {
          return InfoBar(
            title: Text(context.l10n.commonError),
            content: Text(e.toString()),
            severity: InfoBarSeverity.error,
            onClose: close,
          );
        });
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: context.l10n.settingsBackup,
      child: Row(
        children: [
          Button(
            onPressed: _isExporting ? null : _exportBackup,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FluentIcons.download, size: AppIconSize.md),
                const SizedBox(width: AppSpacing.sm),
                Text(context.l10n.settingsExport),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Button(
            onPressed: _isImporting ? null : _importBackup,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FluentIcons.upload, size: AppIconSize.md),
                const SizedBox(width: AppSpacing.sm),
                Text(context.l10n.settingsImport),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
