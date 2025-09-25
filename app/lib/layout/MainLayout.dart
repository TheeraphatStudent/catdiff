import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/config/share/app_data.dart';

class MainLayout extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool showHeader;
  final bool showFooter;

  const MainLayout({
    super.key,
    required this.body,
    this.appBar,
    this.showHeader = true,
    this.showFooter = true,
  });

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: appData.themeToken.color),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        // appBar: appBar ?? (showHeader ? const Header() : null),
        body: body,
        // bottomNavigationBar: showFooter ? const Footer() : null,
      ),
    );
  }
}
