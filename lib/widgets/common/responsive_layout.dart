import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// A widget that renders different layouts based on screen width.
///
/// Simplifies the common LayoutBuilder + breakpoint pattern used across screens.
/// Uses [Breakpoints] for consistent breakpoint values.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.compact,
    required this.expanded,
    this.medium,
  });

  /// Layout for compact screens (< [Breakpoints.medium])
  final Widget compact;

  /// Layout for expanded screens (>= [Breakpoints.medium])
  final Widget expanded;

  /// Optional layout for medium screens ([Breakpoints.compact] to [Breakpoints.medium])
  /// If not provided, uses [compact] for this range.
  final Widget? medium;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.medium) {
          return expanded;
        }
        if (medium != null && constraints.maxWidth >= Breakpoints.compact) {
          return medium!;
        }
        return compact;
      },
    );
  }
}
