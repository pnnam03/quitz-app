import 'package:flutter/material.dart';

class VisibilityButton extends StatelessWidget {
  final double? height;
  final double? width;
  final VoidCallback onPressed;
  final EdgeInsets? margin;
  final String? text;
  final bool? visible;
  final ButtonStyle? buttonStyle;
  final TextStyle? textStyle;

  VisibilityButton({
    this.height,
    this.width,
    this.margin,
    this.text,
    this.visible,
    this.buttonStyle,
    this.textStyle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: visible ?? true,
        child: Container(
            width: width,
            height: height,
            margin: margin,
            child: ElevatedButton(
              onPressed: onPressed,
              child: Text(text ?? "", style: textStyle),
              style: buttonStyle,
            )));
  }
}
