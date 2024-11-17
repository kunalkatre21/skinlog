import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skin_log/models/routine.dart';
import 'package:skin_log/services/mock_service.dart';
import 'package:table_calendar/table_calendar.dart';

final selectedDateProvider = StateProvider((ref) => DateTime.now());

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final mockService = ref.watch(mockDataProvider);
    final routines = mockService.getRoutines();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add mock routine for testing
              mockService.addRoutine(
                RoutineEntry(
                  id: DateTime.now().toString(),
                  userId: 'test-user',
                  routineTime: RoutineTime.morning,
                  steps: [
                    RoutineStep(
                      id: '1',
                      name: 'Cleanse face',
                      completed: false,
                    ),
                    RoutineStep(
                      id: '2',
                      name: 'Apply moisturizer',
                      completed: false,
                    ),
                  ],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
              // Force rebuild
              ref.invalidate(mockDataProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: selectedDate,
              selectedDayPredicate: (day) {
                return isSameDay(selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                ref.read(selectedDateProvider.notifier).state = selectedDay;
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
              ),
            ),
          ),
          Expanded(
            child: routines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.face_retouching_natural,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No routines for this day',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Routine'),
                          onPressed: () {
                            // Add mock routine
                            mockService.addRoutine(
                              RoutineEntry(
                                id: DateTime.now().toString(),
                                userId: 'test-user',
                                routineTime: RoutineTime.morning,
                                steps: [
                                  RoutineStep(
                                    id: '1',
                                    name: 'Cleanse face',
                                    completed: false,
                                  ),
                                  RoutineStep(
                                    id: '2',
                                    name: 'Apply moisturizer',
                                    completed: false,
                                  ),
                                ],
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              ),
                            );
                            // Force rebuild
                            ref.invalidate(mockDataProvider);
                          },
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      final routine = routines[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            routine.routineTime == RoutineTime.morning
                                ? 'Morning Routine'
                                : 'Evening Routine',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: routine.steps
                                .map(
                                  (step) => CheckboxListTile(
                                    title: Text(step.name),
                                    value: step.completed,
                                    onChanged: (value) {
                                      final updatedSteps = routine.steps
                                          .map((s) => s.id == step.id
                                              ? s.copyWith(
                                                  completed: value ?? false)
                                              : s)
                                          .toList();
                                      mockService.updateRoutine(
                                        routine.copyWith(steps: updatedSteps),
                                      );
                                      // Force rebuild
                                      ref.invalidate(mockDataProvider);
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              mockService.deleteRoutine(routine.id);
                              // Force rebuild
                              ref.invalidate(mockDataProvider);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
