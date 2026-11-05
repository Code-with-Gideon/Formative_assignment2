import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_colors.dart';
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
    final Widget content = _buildImageContent(context);

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }
    return content;
  }

  Widget _buildImageContent(BuildContext context) {
    final raw = imageUrl?.trim() ?? '';
    if (raw.isEmpty) {
      return _buildPlaceholder();
    }

    // 1. Local file path check (for rapid local preview)
    if (!kIsWeb && (raw.startsWith('/') || raw.contains(':\\') || raw.startsWith('file:'))) {
      try {
        final sanitizedPath = raw.replaceFirst('file://', '');
        final file = File(sanitizedPath);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => _buildPlaceholder(failureReason: 'Local photo inaccessible'),
          );
        }
      } catch (e) {
        debugPrint('[IncidentImageView] Local file read error: $e');
      }
    }

    // 2. Base64 Data URI or raw Base64 string
    final isDataUri = raw.startsWith('data:image');
    final isLikelyBase64 = isDataUri || (!raw.startsWith('http') && raw.length > 80);

    if (isLikelyBase64) {
      try {
        final commaIndex = raw.indexOf(',');
        final base64Portion = (commaIndex != -1) ? raw.substring(commaIndex + 1) : raw;
        // Clean out all linebreaks, spaces, and carriage returns that invalidate Dart base64 decoding
        final cleanBase64 = base64Portion.replaceAll(RegExp(r'\s+'), '');
        final bytes = base64Decode(cleanBase64);

        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) {
            debugPrint('[IncidentImageView] Base64 memory decode failed: $err');
            return _buildPlaceholder(failureReason: 'Failed to decode photo data');
          },
        );
      } catch (e) {
        debugPrint('[IncidentImageView] Base64 parse exception: $e');
        return _buildPlaceholder(failureReason: 'Corrupted photo format');
      }
    }

    // 3. Remote HTTP / HTTPS URL (Firebase Cloud Storage)
    return Image.network(
      raw,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: category.color.withValues(alpha: 0.08),
          child: const Center(
            child: CupertinoActivityIndicator(radius: 12),
          ),
        );
      },
      errorBuilder: (ctx, error, stackTrace) {
        debugPrint('[IncidentImageView] Network image failed for URL: $raw ($error)');
        return _buildPlaceholder(failureReason: 'Storage permission / connection error');
      },
    );
  }

  Widget _buildPlaceholder({String? failureReason}) {
    final hasAttachment = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final isSmall = height != null && height! < 100;

    return Container(
      width: width,
      height: height,
      color: category.color.withValues(alpha: 0.12),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              size: isSmall ? 26 : 38,
              color: category.color,
            ),
            if (hasAttachment && !isSmall) ...[
              const SizedBox(height: 10),
              Text(
                failureReason ?? 'Loading photo...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: category.color,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Publish Storage Rules & restart app',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
