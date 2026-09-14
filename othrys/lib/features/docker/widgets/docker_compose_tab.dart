import 'package:fluent_ui/fluent_ui.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/app_console_box.dart';
import '../docker_controller.dart';

/// Single-responsibility widget for managing Docker Compose projects and viewing output.
class DockerComposeTab extends StatelessWidget {
  final DockerState state;
  final TextEditingController composePathController;
  final ValueChanged<String> onRunAction;
  final bool canManage;

  const DockerComposeTab({
    super.key,
    required this.state,
    required this.composePathController,
    required this.onRunAction,
    this.canManage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pageContent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: context.l10n.dockerComposePath,
                  child: TextBox(
                    controller: composePathController,
                    placeholder: '/path/to/project',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: Row(
                  children: [
                    if (canManage) ...[
                      FilledButton(
                        onPressed: state.isComposeRunning ? null : () => onRunAction('up -d'),
                        child: Text(
                          context.l10n.dockerComposeUp,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Button(
                        onPressed: state.isComposeRunning ? null : () => onRunAction('down'),
                        child: Text(context.l10n.dockerComposeDown),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Button(
                        onPressed: state.isComposeRunning ? null : () => onRunAction('restart'),
                        child: Text(context.l10n.dockerRestart),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Button(
                      onPressed: state.isComposeRunning ? null : () => onRunAction('logs --tail 100'),
                      child: Text(context.l10n.dockerComposeLogs),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (state.isComposeRunning)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: ProgressRing(),
              ),
            )
          else if (state.composeOutput != null)
            Expanded(
              child: AppConsoleBox(
                content: state.composeOutput!,
                autoScroll: true,
              ),
            ),
        ],
      ),
    );
  }
}
