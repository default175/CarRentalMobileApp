import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.imageUrl,
    required this.height,
    this.width,
    this.borderRadius = 18,
    this.fit = BoxFit.cover,
    this.errorWidget,
    super.key,
  });

  final String imageUrl;
  final double height;
  final double? width;
  final double borderRadius;
  final BoxFit fit;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => errorWidget ?? const SizedBox.shrink(),
      ),
    );
  }
}
