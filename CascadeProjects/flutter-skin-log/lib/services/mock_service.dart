import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';

// Mock data provider
final mockDataProvider = Provider((ref) => MockDataService());

class MockDataService {
  final List<RoutineEntry> _routines = [];

  List<RoutineEntry> getRoutines() {
    return _routines;
  }

  void addRoutine(RoutineEntry routine) {
    _routines.add(routine);
  }

  void updateRoutine(RoutineEntry updatedRoutine) {
    final index = _routines.indexWhere((r) => r.id == updatedRoutine.id);
    if (index != -1) {
      _routines[index] = updatedRoutine;
    }
  }

  void deleteRoutine(String id) {
    _routines.removeWhere((r) => r.id == id);
  }
}
