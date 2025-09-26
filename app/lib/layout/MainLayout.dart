import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/config/share/app_data.dart';

class MainLayout extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool showHeader;
  final bool showFooter;
  final bool resizeToAvoidBottomInset;
  final EdgeInsets? padding;
  final bool scrollable;

  const MainLayout({
    super.key,
    required this.body,
    this.appBar,
    this.showHeader = true,
    this.showFooter = true,
    this.resizeToAvoidBottomInset = true,
    this.padding,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: appData.themeToken.color),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        // appBar: appBar ?? (showHeader ? const Header() : null),
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: SafeArea(
          child: scrollable
              ? SingleChildScrollView(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        padding ??
                        EdgeInsets.only(
                          bottom: keyboardHeight > 0 ? 16.0 : 0.0,
                        ),
                    child: body,
                  ),
                )
              : AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      padding ??
                      EdgeInsets.only(bottom: keyboardHeight > 0 ? 16.0 : 0.0),
                  child: body,
                ),
        ),
        // bottomNavigationBar: showFooter ? const Footer() : null,
      ),
    );
  }
}
