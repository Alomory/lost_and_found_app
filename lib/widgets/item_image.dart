import 'package:flutter/material.dart';
import 'package:lost_and_founds_simple/model/item.dart';

class ItemImage extends StatelessWidget {
  const ItemImage({
    super.key,
    required this.item,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
  });

  final Item item;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (item.imagePath.isEmpty) {
      imageWidget = _fallbackBox();
    } else if (item.isRemoteImage) {
      imageWidget = Image.network(
        item.imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallbackBox(),
      );
    } else {
      imageWidget = Image.file(
        item.imageFile,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallbackBox(),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: imageWidget,
    );
  }

  Widget _fallbackBox() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFF94A3B8),
        size: 32,
      ),
    );
  }
}
