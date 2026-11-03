import 'package:flutter_test/flutter_test.dart';
import 'package:campus_care/core/constants/app_constants.dart';

void main() {
  test('IncidentStatus parsing handles various formats', () {
    expect(IncidentStatus.fromString('submitted'), IncidentStatus.submitted);
    expect(IncidentStatus.fromString('in_progress'), IncidentStatus.inProgress);
    expect(IncidentStatus.fromString('in progress'), IncidentStatus.inProgress);
    expect(IncidentStatus.fromString('resolved'), IncidentStatus.resolved);
    expect(IncidentStatus.fromString('dismissed'), IncidentStatus.dismissed);
  });

  test('IncidentCategory finds categories by ID correctly', () {
    final cat = IncidentCategory.findById('water');
    expect(cat.name, 'Water');
    expect(cat.id, 'water');
  });
}
