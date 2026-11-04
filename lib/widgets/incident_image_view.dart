import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../core/constants/app_constants.dart';

class IncidentImageView extends StatelessWidget {
  final String? imageUrl;
  final IncidentCategory category;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const IncidentImageView({
    super.key,
    required this.imageUrl,
    required this.category,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      imageWidget = _buildPlaceholder();
    } else if (imageUrl!.startsWith('data:image')) {
      // Decode Base64 data URI
      try {
        final commaIndex = imageUrl!.indexOf(',');
        final base64Data = commaIndex != -1 ? imageUrl!.substring(commaIndex + 1) : imageUrl!;
        final bytes = base64Decode(base64Data);
        imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, _, _) => _buildPlaceholder(),
        );
      } catch (e) {
        imageWidget = _buildPlaceholder();
      }
    } else {
      // Standard HTTP / HTTPS URL from Firebase Storage
      imageWidget = Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: category.color.withValues(alpha: 0.08),
            child: const Center(child: CupertinoActivityIndicator()),
          );
        },
        errorBuilder: (_, _, _) => _buildPlaceholder(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: category.color.withValues(alpha: 0.12),
      child: Center(
        child: Icon(category.icon, size: 28, color: category.color),
      ),
    );
  }
}
