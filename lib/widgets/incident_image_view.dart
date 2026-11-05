import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show showModalBottomSheet;
import 'package:flutter/services.dart';
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
      return _buildPlaceholder(context);
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
            errorBuilder: (_, _, _) => _buildPlaceholder(
              context,
              failureReason: 'Local photo inaccessible',
              rawUrl: raw,
            ),
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
        final cleanBase64 = base64Portion.replaceAll(RegExp(r'\s+'), '');
        final bytes = base64Decode(cleanBase64);

        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) {
            debugPrint('[IncidentImageView] Base64 memory decode failed: $err');
            return _buildPlaceholder(
              context,
              failureReason: 'Failed to decode photo data',
              rawUrl: raw,
            );
          },
        );
      } catch (e) {
        debugPrint('[IncidentImageView] Base64 parse exception: $e');
        return _buildPlaceholder(
          context,
          failureReason: 'Corrupted photo format',
          rawUrl: raw,
        );
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
        final errText = error.toString();
        debugPrint('[IncidentImageView] Network image failed for URL: $raw ($errText)');

        String diagnosticHint = 'Storage Rules need to allow public read';
        if (errText.contains('Permission denied') || errText.contains('SocketException')) {
          diagnosticHint = 'OS permission denied (rebuild app with flutter run)';
        } else if (errText.contains('403')) {
          diagnosticHint = 'HTTP 403: Storage Rules locked in Firebase Console';
        }

        return _buildPlaceholder(
          context,
          failureReason: diagnosticHint,
          rawUrl: raw,
          detailedError: errText,
        );
      },
    );
  }

  Widget _buildPlaceholder(
    BuildContext context, {
    String? failureReason,
    String? rawUrl,
    String? detailedError,
  }) {
    final hasAttachment = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final isSmall = height != null && height! < 100;

    final container = Container(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  failureReason ?? 'Loading photo...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: category.color,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Tap to inspect diagnostics & copy URL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (hasAttachment && !isSmall) {
      return GestureDetector(
        onTap: () => _showDiagnosticsModal(context, rawUrl, detailedError),
        child: container,
      );
    }

    return container;
  }

  void _showDiagnosticsModal(BuildContext context, String? url, String? error) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.info_circle_fill, color: category.color, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Photo Diagnostics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Firebase Storage Download URL:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.lightBorder.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  url ?? 'No URL provided',
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Error Log:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  error,
                  style: const TextStyle(fontSize: 11, color: CupertinoColors.systemRed),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                      onPressed: () {
                        if (url != null) {
                          Clipboard.setData(ClipboardData(text: url));
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Photo URL copied to clipboard! Paste in browser to test.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: const Text('Copy URL', style: TextStyle(fontSize: 14, color: CupertinoColors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    color: AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(10),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close', style: TextStyle(fontSize: 14, color: AppColors.lightTextPrimary)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
