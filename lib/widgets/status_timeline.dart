import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/incident_model.dart';
import '../models/timeline_event_model.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';

class StatusTimelineWidget extends StatelessWidget {
  final IncidentModel incident;
  final List<TimelineEventModel> events;

  const StatusTimelineWidget({
    super.key,
    required this.incident,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final stages = [
      IncidentStatus.submitted,
      IncidentStatus.inProgress,
      IncidentStatus.resolved,
    ];

    int currentStageIndex = 0;
    if (incident.status == IncidentStatus.inProgress) {
      currentStageIndex = 1;
    } else if (incident.status == IncidentStatus.resolved) {
      currentStageIndex = 2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Timeline',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Visual 3-Stage Progress Bar
        Row(
          children: List.generate(stages.length, (index) {
            final stage = stages[index];
            final isReached = index <= currentStageIndex;
            final isCurrent = index == currentStageIndex;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isReached ? stage.color : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              isReached ? CupertinoIcons.check_mark : CupertinoIcons.circle,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          stage.displayName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                            color: isReached
                                ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < stages.length - 1)
                    Container(
                      width: 24,
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      color: index < currentStageIndex
                          ? AppColors.statusResolved
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 20),

        // Detailed Event List
        if (events.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 5, right: 12),
                      decoration: BoxDecoration(
                        color: event.status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                event.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              Text(
                                DateFormatter.formatFull(event.timestamp),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (event.note != null && event.note!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              event.note!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
