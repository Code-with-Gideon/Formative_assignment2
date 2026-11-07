import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/incident_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/alu_brand.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/empty_state_view.dart';
import 'create_incident_screen.dart';
import 'incident_details_screen.dart';
import 'my_reports_screen.dart';
import '../shared/profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _StudentDashboardTab(),
      const MyReportsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex == 2 ? 2 : _currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateIncidentScreen()),
          );
        },
        backgroundColor: AppColors.aluRed,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(CupertinoIcons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: CupertinoIcons.house_fill, label: 'Home', index: 0),
              _buildNavItem(icon: CupertinoIcons.doc_text_fill, label: 'Reports', index: 1),
              const SizedBox(width: 48), // gap for centered FAB
              _buildNavItem(icon: CupertinoIcons.bell_fill, label: 'Campus Feed', index: 3),
              _buildNavItem(icon: CupertinoIcons.person_fill, label: 'Profile', index: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.aluRed : AppColors.aluNavy;
    final inactiveColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return InkWell(
      onTap: () {
        if (index == 3) {
          // Open public campus reports list
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const _CampusFeedScreen()),
          );
        } else {
          setState(() => _currentIndex = index);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentDashboardTab extends StatelessWidget {
  const _StudentDashboardTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final incidentProvider = context.watch<IncidentProvider>();
    final user = authProvider.currentUser;

    final firstName = user?.fullName.split(' ').first ?? 'Student';

    return SafeArea(
      child: StreamBuilder<List<IncidentModel>>(
        stream: incidentProvider.getAllCampusIncidentsStream(),
        builder: (context, snapshot) {
          final allIncidents = snapshot.data ?? [];
          final myIncidents = allIncidents.where((i) => i.studentId == user?.uid).toList();
          final stats = incidentProvider.computeStats(myIncidents);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand Header & Greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const AluMark(size: 42, radius: 10),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Hello, $firstName',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text('👋', style: TextStyle(fontSize: 20)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ALU Kigali Campus Operations',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                      },
                      child: CircleAvatar(
                        radius: 21,
                        backgroundColor: AppColors.aluNavy,
                        child: Text(
                          firstName.isNotEmpty ? firstName[0].toUpperCase() : 'A',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ALU Navy + Red Action Hero Banner
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.aluNavy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.aluNavy,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top ALU red signature stripe
                        Container(
                          height: 5,
                          width: double.infinity,
                          color: AppColors.aluRed,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'See an issue\non campus?',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.4,
                                        height: 1.18,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.aluRed,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'LIVE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Report broken facilities, water or power faults and track resolution directly with campus staff.',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CreateIncidentScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.aluNavy,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  CupertinoIcons.plus_circle_fill,
                                  size: 18,
                                  color: AppColors.aluRed,
                                ),
                                label: const Text(
                                  'Report an Issue',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Report Summary Stats Cards matching Page 3
                StatsSummaryCards(
                  total: stats['total'] ?? 0,
                  inProgress: stats['inProgress'] ?? 0,
                  resolved: stats['resolved'] ?? 0,
                  submitted: stats['submitted'] ?? 0,
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyReportsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Recent Reports Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Reports',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const _CampusFeedScreen()),
                        );
                      },
                      child: const Text('See all', style: TextStyle(color: AppColors.primaryLight)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CupertinoActivityIndicator(),
                    ),
                  )
                else if (allIncidents.isEmpty)
                  const EmptyStateView(
                    title: 'No reports yet',
                    message: 'Be the first to report an issue on campus using the button above.',
                    icon: CupertinoIcons.bell_circle,
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allIncidents.take(4).length,
                    itemBuilder: (context, index) {
                      final inc = allIncidents[index];
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
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CampusFeedScreen extends StatefulWidget {
  const _CampusFeedScreen();

  @override
  State<_CampusFeedScreen> createState() => _CampusFeedScreenState();
}

class _CampusFeedScreenState extends State<_CampusFeedScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incidentProvider = context.watch<IncidentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Reports Feed'),
      ),
      body: StreamBuilder<List<IncidentModel>>(
        stream: incidentProvider.getAllCampusIncidentsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }

          final all = snapshot.data ?? [];
          final filtered = incidentProvider.filterList(all);

          return Column(
            children: [
              // Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: incidentProvider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search by title, location, or issue...',
                    prefixIcon: const Icon(CupertinoIcons.search, size: 18),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(CupertinoIcons.clear_circled, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              incidentProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Filter Category Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All Categories'),
                      selected: incidentProvider.selectedCategory == 'all',
                      onSelected: (_) => incidentProvider.setCategoryFilter('all'),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: incidentProvider.selectedCategory == 'all' ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...IncidentCategory.all.map((c) {
                      final isSelected = incidentProvider.selectedCategory == c.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(c.name),
                          selected: isSelected,
                          onSelected: (_) => incidentProvider.setCategoryFilter(c.id),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // List
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyStateView(
                        title: 'No matching reports',
                        message: 'Try clearing your search query or choosing another category.',
                        icon: CupertinoIcons.search,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final inc = filtered[index];
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
}
