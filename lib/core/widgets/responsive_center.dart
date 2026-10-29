import 'package:flutter/material.dart';

/// Centers child and limits its maximum width for optimal readability
/// on larger displays (tablets, desktop web, Chrome) while maintaining
/// native edge-to-edge layouts on mobile screens.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 760,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > maxWidth) {
          return Center(
            child: SizedBox(
              width: maxWidth,
              child: content,
            ),
          );
        }
        return content;
      },
    );
  }
}
