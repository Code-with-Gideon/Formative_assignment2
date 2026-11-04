import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/incident_model.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import 'status_badge.dart';
import 'incident_image_view.dart';

class IncidentCard extends StatelessWidget {
  final IncidentModel incident;
  final VoidCallback onTap;

  const IncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = incident.categoryInfo;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Thumbnail (Firebase Storage or Fallback)
              IncidentImageView(
                imageUrl: incident.imageUrl,
                category: category,
                width: 72,
                height: 72,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            incident.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        StatusBadge(status: incident.status, isCompact: true),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.location_solid, size: 13, color: AppColors.primaryLight),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            incident.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: category.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(category.icon, size: 10, color: category.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    category.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: category.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          DateFormatter.formatTimeAgo(incident.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
