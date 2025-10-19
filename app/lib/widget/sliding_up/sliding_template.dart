import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class SlidingTemplate extends StatefulWidget {
  // -#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

  final List<Widget> children;

  /// Whether the modal is currently opened
  final bool isOpened;

  /// Callback when modal is closed
  final VoidCallback? onModalClosed;

  /// Whether to show action button that opens the modal
  final bool isShowingAction;

  /// Text for the action button
  final String actionButtonText;

  /// Icon for the action button
  final IconData? actionButtonIcon;

  /// Custom action button widget
  final Widget? customActionButton;

  /// Custom top bar widget (optional)
  final Widget? customTopBar;

  /// Height of the top bar (default: 60)
  final double topBarHeight;

  /// Modal type breakpoint for responsive design
  final double modalBreakpoint;

  /// Whether the modal can be dismissed by tapping barrier
  final bool barrierDismissible;

  /// Whether drag to dismiss is enabled
  final bool enableDrag;

  /// Padding for the content
  final EdgeInsets contentPadding;

  // -#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

  const SlidingTemplate({
    super.key,
    required this.children,
    this.isOpened = false,
    this.onModalClosed,

    this.isShowingAction = false,
    this.actionButtonText = 'Open',
    this.actionButtonIcon,
    this.customActionButton,

    this.customTopBar,
    this.topBarHeight = 60.0,
    this.modalBreakpoint = 768.0,
    this.barrierDismissible = true,
    this.enableDrag = true,
    this.contentPadding = const EdgeInsets.all(16.0),
  });

  @override
  State<SlidingTemplate> createState() => _SlidingTemplateState();
}

class _SlidingTemplateState extends State<SlidingTemplate> {
  bool _isModalCurrentlyOpen = false;
  bool _hasProcessedOpenRequest = false;

  @override
  void didUpdateWidget(SlidingTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isOpened &&
        !oldWidget.isOpened &&
        !_isModalCurrentlyOpen &&
        !_hasProcessedOpenRequest) {
      _hasProcessedOpenRequest = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openModal();
      });
    }

    if (!widget.isOpened && oldWidget.isOpened) {
      _hasProcessedOpenRequest = false;
    }
  }

  void _openModal() {
    if (_isModalCurrentlyOpen) {
      return;
    }

    _isModalCurrentlyOpen = true;

    WoltModalSheet.show<void>(
          context: context,
          pageListBuilder: (modalSheetContext) {
            return [_buildModalPage(modalSheetContext)];
          },
          modalTypeBuilder: (context) {
            final size = MediaQuery.sizeOf(context).width;
            if (size < widget.modalBreakpoint) {
              return const WoltBottomSheetType();
            } else {
              return const WoltDialogType();
            }
          },
          barrierDismissible: widget.barrierDismissible,
          enableDrag: widget.enableDrag,
          onModalDismissedWithBarrierTap: () {
            _handleModalClose();
          },
        )
        .then((_) {
          _handleModalClose();
        })
        .catchError((error) {
          _handleModalClose();
        });
  }

  void _handleModalClose() {
    log("Handle modal close wotk!");

    _isModalCurrentlyOpen = false;
    _hasProcessedOpenRequest = false;
    widget.onModalClosed?.call();
  }

  SliverWoltModalSheetPage _buildModalPage(BuildContext modalSheetContext) {
    return SliverWoltModalSheetPage(
      isTopBarLayerAlwaysVisible: true,
      topBar: widget.customTopBar != null
          // ? Container(
          //     height: widget.topBarHeight,
          //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          //     child: widget.customTopBar,
          //   )
          ? SizedBox(height: widget.topBarHeight, child: widget.customTopBar)
          : null,
      mainContentSliversBuilder: (context) => [
        SliverPadding(
          padding: widget.contentPadding,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < widget.children.length) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: widget.children[index],
                );
              }
              return null;
            }, childCount: widget.children.length),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isShowingAction) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.customActionButton ??
              ElevatedButton.icon(
                onPressed: _openModal,
                icon: widget.actionButtonIcon != null
                    ? Icon(widget.actionButtonIcon)
                    : const Icon(Icons.arrow_upward),
                label: Text(widget.actionButtonText),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class SlidingPlaceholderItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const SlidingPlaceholderItem({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: ListTile(
        leading: icon != null ? Icon(icon) : null,
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        onTap: onTap,
        trailing: onTap != null ? const Icon(Icons.arrow_forward_ios) : null,
      ),
    );
  }
}
