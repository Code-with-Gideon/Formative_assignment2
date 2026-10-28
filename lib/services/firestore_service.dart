import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident_model.dart';
import '../models/timeline_event_model.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _incidents => _firestore.collection('incidents');

  // Create a new incident report
  Future<String> createIncident(IncidentModel incident) async {
    final docRef = _incidents.doc();
    final newIncident = IncidentModel(
      id: docRef.id,
      title: incident.title,
      description: incident.description,
      category: incident.category,
      location: incident.location,
      imageUrl: incident.imageUrl,
      status: IncidentStatus.submitted,
      studentId: incident.studentId,
      studentName: incident.studentName,
      studentEmail: incident.studentEmail,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await docRef.set(newIncident.toMap());

    // Record the first timeline entry
    await docRef.collection('timeline').add({
      'title': 'Report Submitted',
      'note': 'Incident logged by ${incident.studentName}.',
      'status': IncidentStatus.submitted.name,
      'authorName': incident.studentName,
      'authorRole': 'student',
      'timestamp': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // Stream all incidents ordered by creation date
  Stream<List<IncidentModel>> getIncidentsStream({
    String? studentId,
    String? category,
    IncidentStatus? status,
  }) {
    Query query = _incidents.orderBy('createdAt', descending: true);

    if (studentId != null && studentId.isNotEmpty) {
      query = query.where('studentId', isEqualTo: studentId);
    }
    if (category != null && category.isNotEmpty && category != 'all') {
      query = query.where('category', isEqualTo: category);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => IncidentModel.fromFirestore(doc)).toList();
    });
  }

  // Stream a single incident for live details view
  Stream<IncidentModel?> getIncidentStream(String incidentId) {
    return _incidents.doc(incidentId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return IncidentModel.fromFirestore(doc);
    });
  }

  // Stream timeline milestones for an incident
  Stream<List<TimelineEventModel>> getIncidentTimeline(String incidentId) {
    return _incidents
        .doc(incidentId)
        .collection('timeline')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TimelineEventModel.fromFirestore(doc))
          .toList();
    });
  }

  // Staff update incident status
  Future<void> updateIncidentStatus({
    required String incidentId,
    required IncidentStatus newStatus,
    required String staffName,
    String? staffNotes,
  }) async {
    final incidentRef = _incidents.doc(incidentId);

    await incidentRef.update({
      'status': newStatus.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'staffNotes': staffNotes,
      'assignedStaffName': staffName,
    });

    // Add milestone event to timeline
    await incidentRef.collection('timeline').add({
      'title': 'Status changed to ${newStatus.displayName}',
      'note': staffNotes ?? 'Status updated by campus staff.',
      'status': newStatus.name,
      'authorName': staffName,
      'authorRole': 'staff',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Delete incident (student can cancel own submitted report or staff admin)
  Future<void> deleteIncident(String incidentId) async {
    await _incidents.doc(incidentId).delete();
  }
}
