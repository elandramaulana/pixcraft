import 'package:flutter/material.dart';
import '../constants/layout_constants.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= LayoutConstants.desktopBreakpoint && desktop != null) {
      return desktop!;
    }

    if (width >= LayoutConstants.mobileBreakpoint && tablet != null) {
      return tablet!;
    }

    return mobile;
  }
}
