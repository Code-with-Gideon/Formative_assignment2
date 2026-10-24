import 'package:flutter/cupertino.dart';
import 'app_colors.dart';

enum IncidentStatus {
  submitted,
  inProgress,
  resolved,
  dismissed;

  String get displayName {
    switch (this) {
      case IncidentStatus.submitted:
        return 'Submitted';
      case IncidentStatus.inProgress:
        return 'In Progress';
      case IncidentStatus.resolved:
        return 'Resolved';
      case IncidentStatus.dismissed:
        return 'Dismissed';
    }
  }

  Color get color {
    switch (this) {
      case IncidentStatus.submitted:
        return AppColors.statusSubmitted;
      case IncidentStatus.inProgress:
        return AppColors.statusInProgress;
      case IncidentStatus.resolved:
        return AppColors.statusResolved;
      case IncidentStatus.dismissed:
        return AppColors.statusDismissed;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case IncidentStatus.submitted:
        return AppColors.statusSubmittedBg;
      case IncidentStatus.inProgress:
        return AppColors.statusInProgressBg;
      case IncidentStatus.resolved:
        return AppColors.statusResolvedBg;
      case IncidentStatus.dismissed:
        return AppColors.statusDismissedBg;
    }
  }

  static IncidentStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
      case 'in progress':
        return IncidentStatus.inProgress;
      case 'resolved':
        return IncidentStatus.resolved;
      case 'dismissed':
        return IncidentStatus.dismissed;
      case 'submitted':
      default:
        return IncidentStatus.submitted;
    }
  }
}

class IncidentCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const IncidentCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<IncidentCategory> all = [
    IncidentCategory(
      id: 'facilities',
      name: 'Facilities',
      icon: CupertinoIcons.building_2_fill,
      color: AppColors.catFacilities,
    ),
    IncidentCategory(
      id: 'water',
      name: 'Water',
      icon: CupertinoIcons.drop_fill,
      color: AppColors.catWater,
    ),
    IncidentCategory(
      id: 'electricity',
      name: 'Electricity',
      icon: CupertinoIcons.bolt_fill,
      color: AppColors.catElectricity,
    ),
    IncidentCategory(
      id: 'safety',
      name: 'Safety',
      icon: CupertinoIcons.shield_fill,
      color: AppColors.catSafety,
    ),
    IncidentCategory(
      id: 'sanitation',
      name: 'Sanitation',
      icon: CupertinoIcons.trash_fill,
      color: AppColors.catSanitation,
    ),
    IncidentCategory(
      id: 'furniture',
      name: 'Furniture',
      icon: CupertinoIcons.bed_double_fill,
      color: AppColors.catFurniture,
    ),
  ];

  static IncidentCategory findById(String id) {
    return all.firstWhere(
      (c) => c.id.toLowerCase() == id.toLowerCase(),
      orElse: () => all[0],
    );
  }
}

class CampusLocations {
  static const List<String> options = [
    'Block A - Classrooms',
    'Block B - Labs',
    'Block B - Room 204',
    'Library - Ground Floor',
    'Library - Study Hall',
    'Cafeteria & Dining Hall',
    'Student Residence - Block 1',
    'Student Residence - Block 2',
    'Leadership Center',
    'Sports & Recreation Area',
    'Administration Building',
  ];
}
