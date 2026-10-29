import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatsSummaryCards extends StatelessWidget {
  final int total;
  final int inProgress;
  final int resolved;
  final int submitted;
  final VoidCallback? onSeeAll;

  const StatsSummaryCards({
    super.key,
    required this.total,
    required this.inProgress,
    required this.resolved,
    required this.submitted,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Report Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            if (onSeeAll != null)
              TextButton(
                onPressed: onSeeAll,
                child: const Text('See all', style: TextStyle(color: AppColors.primaryLight)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatItem(
              context: context,
              icon: CupertinoIcons.doc_text_fill,
              iconColor: const Color(0xFF6366F1),
              count: total,
              label: 'Total Reports',
            ),
            const SizedBox(width: 8),
            _buildStatItem(
              context: context,
              icon: CupertinoIcons.time_solid,
              iconColor: AppColors.statusInProgress,
              count: inProgress,
              label: 'In Progress',
            ),
            const SizedBox(width: 8),
            _buildStatItem(
              context: context,
              icon: CupertinoIcons.check_mark_circled_solid,
              iconColor: AppColors.statusResolved,
              count: resolved,
              label: 'Resolved',
            ),
            const SizedBox(width: 8),
            _buildStatItem(
              context: context,
              icon: CupertinoIcons.exclamationmark_circle_fill,
              iconColor: AppColors.statusSubmitted,
              count: submitted,
              label: 'Submitted',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required int count,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
