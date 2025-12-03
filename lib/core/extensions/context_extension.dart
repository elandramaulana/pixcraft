import 'package:flutter/material.dart';
import '../constants/layout_constants.dart';

extension ContextExtensions on BuildContext {
  // Theme
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  // Media Query
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  // Responsive Helpers
  bool get isMobile => screenWidth < LayoutConstants.mobileBreakpoint;
  bool get isTablet =>
      screenWidth >= LayoutConstants.mobileBreakpoint &&
      screenWidth < LayoutConstants.tabletBreakpoint;
  bool get isDesktop => screenWidth >= LayoutConstants.desktopBreakpoint;

  // Grid Columns
  int get gridColumns {
    if (isMobile) return LayoutConstants.gridCrossAxisCountMobile;
    return LayoutConstants.gridCrossAxisCountTablet;
  }

  // Safe Area
  double get topPadding => padding.top;
  double get bottomPadding => padding.bottom;

  // Navigation
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  // Show SnackBar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LayoutConstants.radiusMedium),
        ),
      ),
    );
  }
}
