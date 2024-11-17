import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skin_log/models/routine.dart';
import 'package:skin_log/providers/auth_provider.dart';
import 'package:skin_log/services/routine_service.dart';

final routineServiceProvider = Provider<RoutineService>((ref) => RoutineService());

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final routineEntriesProvider = StreamProvider<List<RoutineEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  
  if (user == null) return Stream.value([]);
  
  return ref
      .watch(routineServiceProvider)
      .getRoutineEntriesForDate(user.uid, selectedDate);
});

final weeklyRoutineEntriesProvider = StreamProvider<List<RoutineEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 7));
  
  if (user == null) return Stream.value([]);
  
  return ref
      .watch(routineServiceProvider)
      .getRoutineEntriesForDateRange(user.uid, startOfWeek, endOfWeek);
});

class RoutineState {
  final bool isLoading;
  final String? error;
  final List<RoutineEntry> entries;

  RoutineState({
    this.isLoading = false,
    this.error,
    this.entries = const [],
  });

  RoutineState copyWith({
    bool? isLoading,
    String? error,
    List<RoutineEntry>? entries,
  }) {
    return RoutineState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      entries: entries ?? this.entries,
    );
  }
}

class RoutineNotifier extends StateNotifier<RoutineState> {
  final RoutineService _routineService;
  final String userId;

  RoutineNotifier(this._routineService, this.userId) : super(RoutineState());

  Future<void> createRoutineEntry({
    required RoutineTime routineTime,
    required List<RoutineStep> steps,
    String? notes,
    String? skinCondition,
    List<File>? photos,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _routineService.createRoutineEntry(
        userId: userId,
        routineTime: routineTime,
        steps: steps,
        notes: notes,
        skinCondition: skinCondition,
        photos: photos,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateRoutineEntry(
    String entryId, {
    List<RoutineStep>? steps,
    String? notes,
    String? skinCondition,
    List<File>? newPhotos,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _routineService.updateRoutineEntry(
        entryId,
        steps: steps,
        notes: notes,
        skinCondition: skinCondition,
        newPhotos: newPhotos,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteRoutineEntry(String entryId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _routineService.deleteRoutineEntry(entryId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateRoutineStepStatus(
    String entryId,
    String stepId,
    bool completed,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _routineService.updateRoutineStepStatus(
        entryId,
        stepId,
        completed,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final routineNotifierProvider =
    StateNotifierProvider<RoutineNotifier, RoutineState>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('User must be logged in');
  
  final routineService = ref.watch(routineServiceProvider);
  return RoutineNotifier(routineService, user.uid);
});
