import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/incident_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/empty_state_view.dart';
import 'incident_details_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  String _activeTab = 'all';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final incidentProvider = context.watch<IncidentProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not signed in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
      ),
      body: StreamBuilder<List<IncidentModel>>(
        stream: incidentProvider.getMyReportsStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }

          final allMyReports = snapshot.data ?? [];
          final stats = incidentProvider.computeStats(allMyReports);

          // Filter by active tab
          List<IncidentModel> displayedList = allMyReports;
          if (_activeTab == 'submitted') {
            displayedList = allMyReports.where((i) => i.status == IncidentStatus.submitted).toList();
          } else if (_activeTab == 'in_progress') {
            displayedList = allMyReports.where((i) => i.status == IncidentStatus.inProgress).toList();
          } else if (_activeTab == 'resolved') {
            displayedList = allMyReports.where((i) => i.status == IncidentStatus.resolved).toList();
          }

          return Column(
            children: [
              // User Profile Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'S',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.fullName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Student',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Summary Stats Mini Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniStat('Total', stats['total'] ?? 0, AppColors.primary),
                    _buildMiniStat('In Progress', stats['inProgress'] ?? 0, AppColors.statusInProgress),
                    _buildMiniStat('Resolved', stats['resolved'] ?? 0, AppColors.statusResolved),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildTabChip('all', 'All (${allMyReports.length})'),
                    const SizedBox(width: 8),
                    _buildTabChip('submitted', 'Submitted (${stats['submitted']})'),
                    const SizedBox(width: 8),
                    _buildTabChip('in_progress', 'In Progress (${stats['inProgress']})'),
                    const SizedBox(width: 8),
                    _buildTabChip('resolved', 'Resolved (${stats['resolved']})'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // List of Incidents
              Expanded(
                child: displayedList.isEmpty
                    ? const EmptyStateView(
                        title: 'No reports found',
                        message: 'You have not submitted any reports in this category yet.',
                        icon: CupertinoIcons.doc_text_search,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: displayedList.length,
                        itemBuilder: (context, index) {
                          final inc = displayedList[index];
                          return IncidentCard(
                            incident: inc,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => IncidentDetailsScreen(incident: inc),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMiniStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
        ),
      ],
    );
  }

  Widget _buildTabChip(String key, String label) {
    final isSelected = _activeTab == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _activeTab = key),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.lightTextSecondary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
