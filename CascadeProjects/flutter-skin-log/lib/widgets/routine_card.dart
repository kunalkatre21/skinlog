import 'package:flutter/material.dart';
import 'package:skin_log/models/routine.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:skin_log/screens/add_edit_routine_screen.dart';
import 'dart:io';

class RoutineCard extends StatelessWidget {
  final RoutineEntry entry;
  final Function(String, bool) onStepToggled;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RoutineCard({
    super.key,
    required this.entry,
    required this.onStepToggled,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedSteps = entry.steps.where((step) => step.completed).length;
    final progress = entry.steps.isEmpty ? 0.0 : completedSteps / entry.steps.length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              entry.routineTime == RoutineTime.morning
                  ? 'Morning Routine'
                  : 'Evening Routine',
              style: theme.textTheme.titleLarge,
            ),
            subtitle: Text(
              timeago.format(entry.createdAt),
              style: theme.textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditRoutineScreen(
                          routineEntry: entry,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
          if (entry.skinCondition != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Chip(
                label: Text(entry.skinCondition!),
                backgroundColor: theme.colorScheme.primaryContainer,
              ),
            ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entry.steps.length,
            itemBuilder: (context, index) {
              final step = entry.steps[index];
              return CheckboxListTile(
                value: step.completed,
                onChanged: (value) {
                  if (value != null) {
                    onStepToggled(step.id, value);
                  }
                },
                title: Text(step.name),
                subtitle: step.notes != null ? Text(step.notes!) : null,
                secondary: step.iconData != null
                    ? Icon(
                        step.iconData,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              );
            },
          ),
          if (entry.notes != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                entry.notes!,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress: ${(progress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8.0),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          if (entry.photoUrls != null && entry.photoUrls!.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: entry.photoUrls!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        entry.photoUrls![index],
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
