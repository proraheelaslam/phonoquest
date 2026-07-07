import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final bool showAppBar;
  final String? backgroundAsset;
  final Widget? bottomNavigationBar;
  final BoxFit backgroundFit;
  final Alignment backgroundAlignment;

  /// When false, [child] should use its own [SingleChildScrollView] (or list).
  /// Use [pageScrollPadding] on that scroll view so content clears the bottom nav.
  final bool wrapInScrollView;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.showAppBar = true,
    this.backgroundAsset,
    this.bottomNavigationBar,
    this.backgroundFit = BoxFit.cover,
    this.backgroundAlignment = Alignment.center,
    this.wrapInScrollView = true,
  });

  /// Space to leave below scroll content when a bottom nav bar is shown ([extendBody]).
  static double bottomNavClearance(BuildContext context) {
    const navBarHeight = 72.0;
    return navBarHeight + MediaQuery.paddingOf(context).bottom + 20;
  }

  /// Padding for an in-page [SingleChildScrollView] when [wrapInScrollView] is false.
  static EdgeInsets pageScrollPadding(
    BuildContext context, {
    double top = 10,
    double horizontal = 0,
    bool clearBottomNav = true,
  }) {
    final bottom = clearBottomNav ? bottomNavClearance(context) : 24.0;
    return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundAsset ?? AppAssets.signUpBackground;
    final hasBottomNav = bottomNavigationBar != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBody: hasBottomNav,
        extendBodyBehindAppBar: true,
        appBar: showAppBar
            ? AppBar(
                title: Text(title),
                actions: actions,
                automaticallyImplyLeading: automaticallyImplyLeading,
              )
            : null,
        bottomNavigationBar: bottomNavigationBar,
        body: Stack(
          children: [
            Positioned.fill(
              child: bg.toLowerCase().endsWith('.svg')
                  ? SvgPicture.asset(bg, fit: backgroundFit)
                  : Image.asset(bg, fit: backgroundFit, alignment: backgroundAlignment),
            ),
            Positioned.fill(
              child: SafeArea(
                bottom: !hasBottomNav,
                child: wrapInScrollView
                    ? _buildOuterScroll(context, hasBottomNav)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                        child: child,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOuterScroll(BuildContext context, bool hasBottomNav) {
    final bottomPad = hasBottomNav ? bottomNavClearance(context) : 24.0;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 5, 20, bottomPad),
      child: child,
    );
  }
}
