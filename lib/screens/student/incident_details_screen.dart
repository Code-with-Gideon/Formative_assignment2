import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/incident_model.dart';
import '../../models/timeline_event_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/status_timeline.dart';
import '../../widgets/incident_image_view.dart';

class IncidentDetailsScreen extends StatelessWidget {
  final IncidentModel incident;

  const IncidentDetailsScreen({super.key, required this.incident});

  void _confirmDelete(BuildContext context, IncidentModel currentIncident) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancel Incident Report?'),
        content: const Text(
          'This will permanently remove the incident report, its status timeline, and attached photos from the cloud database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Keep Report'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final incidentProvider = context.read<IncidentProvider>();
              final success = await incidentProvider.deleteIncident(
                incidentId: currentIncident.id,
                imageUrl: currentIncident.imageUrl,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Incident report deleted successfully.'
                          : 'Failed to delete report: ${incidentProvider.errorMessage ?? "Unknown error"}',
                    ),
                    backgroundColor:
                        success ? AppColors.statusResolved : Colors.redAccent,
                  ),
                );
                if (success) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Delete Report', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firestore = context.read<FirestoreService>();
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final category = incident.categoryInfo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        actions: [
          if (currentUser != null &&
              (currentUser.isStaff || currentUser.uid == incident.studentId))
            IconButton(
              icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
              tooltip: 'Delete Incident Report',
              onPressed: () => _confirmDelete(context, incident),
            ),
        ],
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
                const SizedBox(height: 16),

                // Title
                Text(
                  liveIncident.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Location Pill
                Row(
                  children: [
                    const Icon(CupertinoIcons.location_solid, size: 14, color: AppColors.aluRed),
                    const SizedBox(width: 4),
                    Text(
                      liveIncident.location,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Author Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        child: Text(
                          liveIncident.studentName.isNotEmpty ? liveIncident.studentName[0].toUpperCase() : 'U',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
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

                // Real-time Status Stepper Header & Events
                StreamBuilder<List<TimelineEventModel>>(
                  stream: firestore.getIncidentTimeline(liveIncident.id),
                  builder: (context, timelineSnapshot) {
                    final events = timelineSnapshot.data ?? [];
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
