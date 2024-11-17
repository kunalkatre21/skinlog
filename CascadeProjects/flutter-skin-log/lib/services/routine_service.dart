import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:skin_log/models/routine.dart';
import 'package:skin_log/services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class RoutineService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final FirebaseStorage _storage = FirebaseService.storage;
  final _uuid = const Uuid();

  // Collection references
  CollectionReference get _routinesCollection =>
      _firestore.collection('routines');

  // Create a new routine entry
  Future<RoutineEntry> createRoutineEntry({
    required String userId,
    required RoutineTime routineTime,
    required List<RoutineStep> steps,
    String? notes,
    String? skinCondition,
    List<File>? photos,
  }) async {
    final now = DateTime.now();
    List<String>? photoUrls;

    // Upload photos if provided
    if (photos != null && photos.isNotEmpty) {
      photoUrls = await Future.wait(
        photos.map((photo) => _uploadPhoto(userId, photo)),
      );
    }

    final entry = RoutineEntry(
      id: _uuid.v4(),
      userId: userId,
      date: DateTime(now.year, now.month, now.day),
      routineTime: routineTime,
      steps: steps,
      notes: notes,
      skinCondition: skinCondition,
      photoUrls: photoUrls,
      createdAt: now,
      updatedAt: now,
    );

    await _routinesCollection.doc(entry.id).set(entry.toFirestore());
    return entry;
  }

  // Get routine entries for a specific date
  Stream<List<RoutineEntry>> getRoutineEntriesForDate(
    String userId,
    DateTime date,
  ) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _routinesCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoutineEntry.fromFirestore(doc))
            .toList());
  }

  // Update a routine entry
  Future<void> updateRoutineEntry(
    String entryId, {
    List<RoutineStep>? steps,
    String? notes,
    String? skinCondition,
    List<File>? newPhotos,
  }) async {
    final doc = await _routinesCollection.doc(entryId).get();
    if (!doc.exists) {
      throw Exception('Routine entry not found');
    }

    final entry = RoutineEntry.fromFirestore(doc);
    List<String> updatedPhotoUrls = entry.photoUrls ?? [];

    // Upload new photos if provided
    if (newPhotos != null && newPhotos.isNotEmpty) {
      final newUrls = await Future.wait(
        newPhotos.map((photo) => _uploadPhoto(entry.userId, photo)),
      );
      updatedPhotoUrls.addAll(newUrls);
    }

    await _routinesCollection.doc(entryId).update({
      if (steps != null) 'steps': steps.map((step) => step.toMap()).toList(),
      if (notes != null) 'notes': notes,
      if (skinCondition != null) 'skinCondition': skinCondition,
      if (newPhotos != null) 'photoUrls': updatedPhotoUrls,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete a routine entry
  Future<void> deleteRoutineEntry(String entryId) async {
    final doc = await _routinesCollection.doc(entryId).get();
    if (!doc.exists) {
      throw Exception('Routine entry not found');
    }

    final entry = RoutineEntry.fromFirestore(doc);
    
    // Delete associated photos
    if (entry.photoUrls != null) {
      await Future.wait(
        entry.photoUrls!.map((url) => _storage.refFromURL(url).delete()),
      );
    }

    await _routinesCollection.doc(entryId).delete();
  }

  // Upload a photo to Firebase Storage
  Future<String> _uploadPhoto(String userId, File photo) async {
    final fileName = '${userId}/${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('routine_photos/$fileName');
    
    await ref.putFile(photo);
    return await ref.getDownloadURL();
  }

  // Get routine entries for a date range
  Stream<List<RoutineEntry>> getRoutineEntriesForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _routinesCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThan: endDate)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoutineEntry.fromFirestore(doc))
            .toList());
  }

  // Update routine step completion status
  Future<void> updateRoutineStepStatus(
    String entryId,
    String stepId,
    bool completed,
  ) async {
    final doc = await _routinesCollection.doc(entryId).get();
    if (!doc.exists) {
      throw Exception('Routine entry not found');
    }

    final entry = RoutineEntry.fromFirestore(doc);
    final updatedSteps = entry.steps.map((step) {
      if (step.id == stepId) {
        return step.copyWith(
          completed: completed,
          completedAt: completed ? DateTime.now() : null,
        );
      }
      return step;
    }).toList();

    await _routinesCollection.doc(entryId).update({
      'steps': updatedSteps.map((step) => step.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
