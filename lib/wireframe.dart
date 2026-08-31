import 'package:flutter/material.dart';

class WireframeBox extends StatelessWidget {
  final double? height;
  final double? width;

  const WireframeBox({
    super.key,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}