import 'dart:developer';

import 'package:flutter/foundation.dart';
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
  final ValueNotifier<int> _rebuildNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(SlidingTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_isModalCurrentlyOpen) {
      bool childrenChanged =
          oldWidget.children.length != widget.children.length;
      if (!childrenChanged) {
        for (int i = 0; i < widget.children.length; i++) {
          if (oldWidget.children[i].runtimeType !=
              widget.children[i].runtimeType) {
            childrenChanged = true;
            break;
          }
        }
      }

      if (childrenChanged || oldWidget.customTopBar != widget.customTopBar) {
        log('SlidingTemplate: Scheduling modal content rebuild');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            log('SlidingTemplate: Executing modal content rebuild');
            _rebuildNotifier.value++;
          }
        });
      }
    }

    if (widget.isOpened &&
        !oldWidget.isOpened &&
        !_isModalCurrentlyOpen &&
        !_hasProcessedOpenRequest) {
      log('SlidingTemplate: Scheduling modal open');
      _hasProcessedOpenRequest = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        log('SlidingTemplate: Opening modal');
        _openModal();
      });
    }

    if (!widget.isOpened && oldWidget.isOpened && _isModalCurrentlyOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _closeModal();
      });
    }

    if (!widget.isOpened && oldWidget.isOpened) {
      _hasProcessedOpenRequest = false;
    }
  }

  void _openModal() {
    log(
      'SlidingTemplate: _openModal called, _isModalCurrentlyOpen: $_isModalCurrentlyOpen',
    );
    if (_isModalCurrentlyOpen) {
      log('SlidingTemplate: Modal already open, returning');
      return;
    }

    log('SlidingTemplate: Setting modal as open and showing WoltModalSheet');
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

  void _closeModal() {
    if (!_isModalCurrentlyOpen) {
      return;
    }

    // Use Navigator to dismiss the modal
    Navigator.of(context).pop();
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
          ? SizedBox(
              height: widget.topBarHeight,
              child: ValueListenableBuilder<int>(
                valueListenable: _rebuildNotifier,
                builder: (context, _, __) => widget.customTopBar!,
              ),
            )
          : null,
      mainContentSliversBuilder: (context) => [
        SliverPadding(
          padding: widget.contentPadding,
          sliver: SliverToBoxAdapter(
            child: ValueListenableBuilder<int>(
              valueListenable: _rebuildNotifier,
              builder: (context, _, __) {
                return Column(
                  children: widget.children
                      .map(
                        (child) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: child,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _rebuildNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log(
      'SlidingTemplate build: isOpened=${widget.isOpened}, isShowingAction=${widget.isShowingAction}, _isModalCurrentlyOpen=$_isModalCurrentlyOpen',
    );
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
