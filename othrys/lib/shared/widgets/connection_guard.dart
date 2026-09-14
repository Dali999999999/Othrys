import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/l10n.dart';
import '../../features/servers/server_controller.dart';
import 'app_empty_state.dart';

/// Standard guard wrapping views that require an active server SSH session.
class ConnectionGuard extends ConsumerWidget {
  final Widget child;
  final String? customMessage;

  const ConnectionGuard({
    super.key,
    required this.child,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(serverControllerProvider).activeSession;

    if (activeSession != null) {
      return child;
    }

    return AppEmptyState(
      icon: FluentIcons.plug_disconnected,
      title: customMessage ?? context.l10n.guardNoConnectionSubtitle,
    );
  }
}

