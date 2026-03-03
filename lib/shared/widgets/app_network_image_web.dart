// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

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

  static final Set<String> _registeredViewTypes = <String>{};

  @override
  Widget build(BuildContext context) {
    final widthToken =
        width != null && width!.isFinite ? width!.round().toString() : 'auto';
    final viewType =
        'network-image-${imageUrl.hashCode}-${height.round()}-$widthToken';

    if (!_registeredViewTypes.contains(viewType)) {
      _registeredViewTypes.add(viewType);
      ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        final image = html.ImageElement()
          ..src = imageUrl
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = _objectFitValue(fit)
          ..style.borderRadius = '${borderRadius}px';
        return image;
      });
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: width != null && width!.isFinite ? width : null,
        child: HtmlElementView(viewType: viewType),
      ),
    );
  }

  String _objectFitValue(BoxFit fit) {
    switch (fit) {
      case BoxFit.contain:
        return 'contain';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.fitHeight:
        return 'scale-down';
      case BoxFit.fitWidth:
        return 'scale-down';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
      case BoxFit.cover:
        return 'cover';
    }
  }
}
