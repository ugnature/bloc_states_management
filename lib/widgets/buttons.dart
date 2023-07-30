import 'package:flutter/material.dart';

// Main Function Button
class FunctionTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double? width;
  final bool baseColor;
  final double? height;
  final Color? onhoverColor;
  const FunctionTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.onhoverColor = Colors.amberAccent,
    this.baseColor = true,
    this.width = 50,
    this.height = 22,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        mouseCursor: SystemMouseCursors.click,
        hoverColor: onhoverColor,
        splashColor: Colors.black26,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: Colors.black12),
            color: Colors.white12,
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          height: height,
          width: width,
          child: Center(child: child),
        ));
  }
}
