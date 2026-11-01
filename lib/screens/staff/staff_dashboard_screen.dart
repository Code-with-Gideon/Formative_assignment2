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
import '../student/incident_details_screen.dart';
import '../shared/profile_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  IncidentStatus? _filterStatus;
  final String _selectedCategory = 'all';

  void _showStatusUpdateDialog(BuildContext context, IncidentModel incident) {
    final authProvider = context.read<AuthProvider>();
    final incidentProvider = context.read<IncidentProvider>();
    final staffUser = authProvider.currentUser;

    IncidentStatus newStatus = incident.status;
    final notesController = TextEditingController(text: incident.staffNotes ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Update Incident Status'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incident.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Status',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<IncidentStatus>(
                  initialValue: newStatus,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: IncidentStatus.values.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => newStatus = val);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Staff Resolution Note',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'e.g. Plumbing contractor assigned. Work underway.',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                final success = await incidentProvider.updateStatus(
                  incidentId: incident.id,
                  newStatus: newStatus,
                  staffName: staffUser?.fullName ?? 'Campus Staff',
                  staffNotes: notesController.text.trim(),
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Incident status updated!' : 'Failed to update status.'),
                      backgroundColor: success ? AppColors.statusResolved : Colors.redAccent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final incidentProvider = context.watch<IncidentProvider>();
    final staff = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Staff Triage'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.person_crop_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<IncidentModel>>(
        stream: incidentProvider.getAllCampusIncidentsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }

          final allIncidents = snapshot.data ?? [];
          final stats = incidentProvider.computeStats(allIncidents);

          // Apply filters
          final filtered = allIncidents.where((i) {
            final matchesStatus = _filterStatus == null || i.status == _filterStatus;
            final matchesCategory = _selectedCategory == 'all' || i.category == _selectedCategory;
            return matchesStatus && matchesCategory;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Staff Greeting & Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: isDark ? AppColors.darkSurface : AppColors.primary.withValues(alpha: 0.06),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 20,
                      child: Icon(CupertinoIcons.shield_lefthalf_fill, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                staff?.fullName ?? 'Authorized Staff',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.statusInProgress,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'STAFF',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            staff?.email ?? '',
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

              // Overview Numbers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    _buildOverviewCard('New Submitted', stats['submitted'] ?? 0, AppColors.statusSubmitted),
                    const SizedBox(width: 8),
                    _buildOverviewCard('In Progress', stats['inProgress'] ?? 0, AppColors.statusInProgress),
                    const SizedBox(width: 8),
                    _buildOverviewCard('Resolved', stats['resolved'] ?? 0, AppColors.statusResolved),
                  ],
                ),
              ),

              // Status Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    _buildFilterChip('All (${allIncidents.length})', null),
                    const SizedBox(width: 8),
                    _buildFilterChip('Submitted (${stats['submitted']})', IncidentStatus.submitted),
                    const SizedBox(width: 8),
                    _buildFilterChip('In Progress (${stats['inProgress']})', IncidentStatus.inProgress),
                    const SizedBox(width: 8),
                    _buildFilterChip('Resolved (${stats['resolved']})', IncidentStatus.resolved),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Incident Queue
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyStateView(
                        title: 'No pending incidents',
                        message: 'No reports match your current filter settings.',
                        icon: CupertinoIcons.checkmark_shield_fill,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final inc = filtered[index];
                          return Stack(
                            children: [
                              IncidentCard(
                                incident: inc,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => IncidentDetailsScreen(incident: inc),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                right: 12,
                                bottom: 20,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showStatusUpdateDialog(context, inc),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                  icon: const Icon(CupertinoIcons.arrow_2_circlepath, size: 12),
                                  label: const Text('Update Status'),
                                ),
                              ),
                            ],
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

  Widget _buildOverviewCard(String title, int count, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IncidentStatus? status) {
    final isSelected = _filterStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filterStatus = status),
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
