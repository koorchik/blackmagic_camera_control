import 'package:flutter/material.dart';

/// A reusable card wrapper with consistent padding.
/// Replaces the repetitive `Card(child: Padding(padding: EdgeInsets.all(16), child: ...))` pattern.
class ControlCard extends StatelessWidget {
  const ControlCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
