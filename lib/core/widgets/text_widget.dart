import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextDecoration? textDecoration;
  final TextOverflow? overFlow;
  final TextAlign? textAlign;
  final EdgeInsets? padding;
  final double? letterSpacing;
  final double? height;

  const TextWidget({
    super.key,
    required this.text,
    this.size,
    this.color,
    this.fontWeight,
    this.maxLines,
    this.textDecoration,
    this.overFlow,
    this.textAlign,
    this.padding,
    this.letterSpacing,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(0),
      child: Text(
        text,
        maxLines: maxLines,
        textAlign: textAlign,
        style: TextStyle(
          height: height,
          color: color ?? Colors.black,
          fontSize: size ?? 14,
          fontWeight: fontWeight ?? FontWeight.normal,
          decoration: textDecoration,
          overflow: overFlow,
          letterSpacing: letterSpacing,
        ),
      ),
    );
  }
}
