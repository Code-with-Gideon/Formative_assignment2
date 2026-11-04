import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/incident_model.dart';
import '../../models/timeline_event_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../services/firestore_service.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/status_timeline.dart';
import '../../widgets/incident_image_view.dart';

class IncidentDetailsScreen extends StatelessWidget {
  final IncidentModel incident;

  const IncidentDetailsScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firestore = FirestoreService();
    final category = incident.categoryInfo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
      ),
      body: StreamBuilder<IncidentModel?>(
        stream: firestore.getIncidentStream(incident.id),
        initialData: incident,
        builder: (context, snapshot) {
          final liveIncident = snapshot.data ?? incident;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Status Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(category.icon, size: 14, color: category.color),
                          const SizedBox(width: 6),
                          Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: category.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: liveIncident.status),
                  ],
                ),
                const SizedBox(height: 14),

                // Title
                Text(
                  liveIncident.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),

                // Location
                Row(
                  children: [
                    const Icon(CupertinoIcons.location_solid, size: 14, color: AppColors.primaryLight),
                    const SizedBox(width: 4),
                    Text(
                      liveIncident.location,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Submitter Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(CupertinoIcons.person_fill, size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reported by ${liveIncident.studentName}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Submitted on ${DateFormatter.formatFull(liveIncident.createdAt)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Status Timeline Stepper
                StreamBuilder<List<TimelineEventModel>>(
                  stream: firestore.getIncidentTimeline(liveIncident.id),
                  builder: (context, timelineSnap) {
                    final events = timelineSnap.data ?? [];
                    return StatusTimelineWidget(
                      incident: liveIncident,
                      events: events,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Description
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Text(
                    liveIncident.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Attached Photo
                if (liveIncident.imageUrl != null && liveIncident.imageUrl!.isNotEmpty) ...[
                  Text(
                    'Attached Photo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  IncidentImageView(
                    imageUrl: liveIncident.imageUrl,
                    category: category,
                    width: double.infinity,
                    height: 240,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
