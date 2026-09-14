import 'package:fluent_ui/fluent_ui.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Dark monospace console container for terminal outputs, streaming logs, and code viewers.
///
/// Remains an indigo dark island (#0B0E18) even in Light Mode as mandated by the Design System v2.0.
class AppConsoleBox extends StatefulWidget {
  /// Raw or formatted monospace text content to display.
  final String content;

  /// Optional fixed height container constraint.
  final double? height;

  /// Whether the view should automatically scroll to the bottom upon receiving new content.
  final bool autoScroll;

  /// Optional external scroll controller.
  final ScrollController? scrollController;

  /// Optional header widget placed above the scrollable text (e.g. streaming status indicator).
  final Widget? header;

  const AppConsoleBox({
    super.key,
    required this.content,
    this.height,
    this.autoScroll = false,
    this.scrollController,
    this.header,
  });

  @override
  State<AppConsoleBox> createState() => _AppConsoleBoxState();
}

class _AppConsoleBoxState extends State<AppConsoleBox> {
  late ScrollController _scrollController;
  bool _internalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      _scrollController = widget.scrollController!;
    } else {
      _scrollController = ScrollController();
      _internalController = true;
    }

    if (widget.autoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  void didUpdateWidget(AppConsoleBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoScroll && widget.content != oldWidget.content) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    if (_internalController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget scrollableText = Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: widget.header != null
            ? const EdgeInsets.only(top: AppSpacing.sm)
            : EdgeInsets.zero,
        child: SizedBox(
          width: double.infinity,
          child: SelectableText(
            widget.content.isEmpty ? ' ' : widget.content,
            style: AppTypo.code(context),
          ),
        ),
      ),
    );

    Widget boxContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.header != null) widget.header!,
        Expanded(child: scrollableText),
      ],
    );

    // If no height constraint is specified, wrap in an intrinsic structure or allow caller to constrain
    if (widget.height != null) {
      boxContent = SizedBox(
        height: widget.height,
        child: boxContent,
      );
    }

    return Container(
      width: double.infinity,
      height: widget.height,
      padding: AppSpacing.consolePadding,
      decoration: BoxDecoration(
        color: AppColors.consoleBackground,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: AppColors.surfaceBorder(context),
          width: 1,
        ),
      ),
      child: widget.height != null
          ? boxContent
          : SingleChildScrollView(
              controller: _scrollController,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.header != null) ...[
                      widget.header!,
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    SelectableText(
                      widget.content.isEmpty ? ' ' : widget.content,
                      style: AppTypo.code(context),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
