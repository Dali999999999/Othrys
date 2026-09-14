import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';
import 'package:flutter/material.dart' show DataTable, DataColumn, DataRow, DataCell;
import '../../../shared/widgets/app_badge.dart';
import '../database_controller.dart';

/// Interactive SQL query runner tab.
class DatabaseQueryTab extends ConsumerStatefulWidget {
  final String sessionId;

  const DatabaseQueryTab({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<DatabaseQueryTab> createState() => _DatabaseQueryTabState();
}

class _DatabaseQueryTabState extends ConsumerState<DatabaseQueryTab> {
  final _queryController = TextEditingController(text: 'SHOW DATABASES;');
  String? _selectedDb;
  bool _isExecuting = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _runQuery() async {
    final sql = _queryController.text.trim();
    if (sql.isEmpty) return;

    setState(() => _isExecuting = true);
    await ref.read(databasesControllerProvider.notifier).executeQuery(
          widget.sessionId,
          sql,
          targetDatabase: _selectedDb,
        );
    if (mounted) {
      setState(() => _isExecuting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(databasesControllerProvider);
    final queryResult = state.lastQueryResult;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Query Input Box & Target DB Selector
          Row(
            children: [
              if (state.databases.isNotEmpty) ...[
                SizedBox(
                  width: 200,
                  child: ComboBox<String?>(
                    value: _selectedDb,
                    placeholder: const Text('Target Database'),
                    items: [
                      const ComboBoxItem(value: null, child: Text('(Default / Server)')),
                      ...state.databases.map((db) => ComboBoxItem(value: db.name, child: Text(db.name))),
                    ],
                    onChanged: (val) => setState(() => _selectedDb = val),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              const Spacer(),
              FilledButton(
                onPressed: _isExecuting ? null : _runQuery,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isExecuting)
                      const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                    else
                      const Icon(FluentIcons.play, size: AppIconSize.xs),
                    const SizedBox(width: AppSpacing.xs),
                    Text(context.l10n.dbQueryRun),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Text input
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.consoleBackground,
              borderRadius: AppRadius.borderSm,
              border: Border.all(color: AppColors.surfaceBorder(context)),
            ),
            child: TextBox(
              controller: _queryController,
              maxLines: null,
              placeholder: context.l10n.dbQueryPlaceholder,
              style: AppTypo.body(context).copyWith(
                fontFamily: AppTypo.fontMono,
                color: AppColors.consoleText,
              ),
              decoration: WidgetStateProperty.all(const BoxDecoration(color: Colors.transparent)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Results header
          if (queryResult != null) ...[
            Row(
              children: [
                Text(context.l10n.dbQueryResults, style: AppTypo.body(context).copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: AppSpacing.sm),
                AppBadge(
                  label: '${queryResult.executionTimeMs} ms',
                  variant: AppBadgeVariant.info,
                ),
                const SizedBox(width: AppSpacing.xs),
                AppBadge(
                  label: '${queryResult.rows.length} rows',
                  variant: AppBadgeVariant.neutral,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Result table or error
          Expanded(
            child: queryResult == null
                ? Center(
                    child: Text(
                      context.l10n.dbQueryPlaceholder,
                      style: AppTypo.body(context).copyWith(color: AppColors.textMuted(context)),
                    ),
                  )
                : queryResult.hasError
                    ? Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.badgeBackground(AppColors.danger),
                          borderRadius: AppRadius.borderSm,
                          border: Border.all(color: AppColors.badgeBorder(AppColors.danger)),
                        ),
                        child: SelectableText(
                          queryResult.error!,
                          style: AppTypo.bodySmall(context).copyWith(
                            color: AppColors.danger,
                            fontFamily: AppTypo.fontMono,
                          ),
                        ),
                      )
                    : queryResult.isEmpty
                        ? Center(
                            child: Text(
                              context.l10n.dbQueryEmpty,
                              style: AppTypo.body(context).copyWith(color: AppColors.textMuted(context)),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard(context),
                              borderRadius: AppRadius.borderSm,
                              border: Border.all(color: AppColors.surfaceBorder(context)),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(AppColors.surfaceElevated(context)),
                                  columns: queryResult.columns
                                      .map((c) => DataColumn(
                                            label: Text(
                                              c,
                                              style: AppTypo.bodySmall(context).copyWith(fontWeight: FontWeight.w600),
                                            ),
                                          ))
                                      .toList(),
                                  rows: queryResult.rows
                                      .map(
                                        (row) => DataRow(
                                          cells: row
                                              .map((val) => DataCell(
                                                    SelectableText(
                                                      val,
                                                      style: AppTypo.caption(context).copyWith(fontFamily: AppTypo.fontMono),
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
