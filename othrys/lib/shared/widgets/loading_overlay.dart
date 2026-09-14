import 'package:fluent_ui/fluent_ui.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Modal or inline overlay presenting a centered progress indicator.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.modalBarrier(context),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ProgressRing(),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    message!,
                    style: AppTypo.body(context).copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

