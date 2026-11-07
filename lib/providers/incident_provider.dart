import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/incident_model.dart';
import '../core/constants/app_constants.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class IncidentProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  String _selectedCategory = 'all';
  IncidentStatus? _selectedStatus;
  String _searchQuery = '';
  bool _isSubmitting = false;
  String? _errorMessage;

  IncidentProvider(this._firestoreService, this._storageService);

  String get selectedCategory => _selectedCategory;
  IncidentStatus? get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  void setCategoryFilter(String categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  void setStatusFilter(IncidentStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = 'all';
    _selectedStatus = null;
    _searchQuery = '';
    notifyListeners();
  }

  // Stream of incidents for student's own reports
  Stream<List<IncidentModel>> getMyReportsStream(String studentId) {
    return _firestoreService.getIncidentsStream(studentId: studentId);
  }

  // Stream of all public campus reports
  Stream<List<IncidentModel>> getAllCampusIncidentsStream() {
    return _firestoreService.getIncidentsStream();
  }

  // Stream single incident
  Stream<IncidentModel?> getIncidentStream(String incidentId) {
    return _firestoreService.getIncidentStream(incidentId);
  }

  // Submit a new incident report with optional photo
  Future<bool> submitIncident({
    required String title,
    required String description,
    required String category,
    required String location,
    XFile? imageFile,
    required String studentId,
    required String studentName,
    required String studentEmail,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? uploadedImageUrl;

      // Temporary ID for photo folder reference
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      if (imageFile != null) {
        uploadedImageUrl = await _storageService.uploadIncidentPhoto(
          file: imageFile,
          incidentId: tempId,
        );
      }

      final incident = IncidentModel(
        id: '',
        title: title.trim(),
        description: description.trim(),
        category: category,
        location: location.trim(),
        imageUrl: uploadedImageUrl,
        status: IncidentStatus.submitted,
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.createIncident(incident);

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // Staff update status with note
  Future<bool> updateStatus({
    required String incidentId,
    required IncidentStatus newStatus,
    required String staffName,
    String? staffNotes,
  }) async {
    try {
      await _firestoreService.updateIncidentStatus(
        incidentId: incidentId,
        newStatus: newStatus,
        staffName: staffName,
        staffNotes: staffNotes,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete an incident report, cleaning up both Cloud Storage photo and Firestore timeline
  Future<bool> deleteIncident({
    required String incidentId,
    String? imageUrl,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _storageService.deletePhoto(imageUrl);
      }
      await _firestoreService.deleteIncident(incidentId);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  // Filter a list in memory by active category, status, and search query
  List<IncidentModel> filterList(List<IncidentModel> items) {
    return items.where((incident) {
      final matchesCategory = _selectedCategory == 'all' ||
          incident.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesStatus =
          _selectedStatus == null || incident.status == _selectedStatus;

      final matchesQuery = _searchQuery.isEmpty ||
          incident.title.toLowerCase().contains(_searchQuery) ||
          incident.description.toLowerCase().contains(_searchQuery) ||
          incident.location.toLowerCase().contains(_searchQuery);

      return matchesCategory && matchesStatus && matchesQuery;
    }).toList();
  }

  // Calculate summary counts
  Map<String, int> computeStats(List<IncidentModel> incidents) {
    int total = incidents.length;
    int inProgress = 0;
    int resolved = 0;
    int submitted = 0;

    for (var inc in incidents) {
      switch (inc.status) {
        case IncidentStatus.inProgress:
          inProgress++;
          break;
        case IncidentStatus.resolved:
          resolved++;
          break;
        case IncidentStatus.submitted:
          submitted++;
          break;
        case IncidentStatus.dismissed:
          break;
      }
    }

    return {
      'total': total,
      'inProgress': inProgress,
      'resolved': resolved,
      'submitted': submitted,
    };
  }
}
