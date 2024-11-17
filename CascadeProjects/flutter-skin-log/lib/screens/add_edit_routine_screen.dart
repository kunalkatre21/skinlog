import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skin_log/models/routine.dart';
import 'package:skin_log/providers/routine_provider.dart';
import 'package:uuid/uuid.dart';

class AddEditRoutineScreen extends ConsumerStatefulWidget {
  final RoutineEntry? routineEntry;

  const AddEditRoutineScreen({
    super.key,
    this.routineEntry,
  });

  @override
  ConsumerState<AddEditRoutineScreen> createState() => _AddEditRoutineScreenState();
}

class _AddEditRoutineScreenState extends ConsumerState<AddEditRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  late RoutineTime _selectedRoutineTime;
  final List<TextEditingController> _stepControllers = [];
  final List<String> _stepIds = [];
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _skinConditionController = TextEditingController();
  List<File> _selectedPhotos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.routineEntry != null) {
      // Editing existing routine
      _selectedRoutineTime = widget.routineEntry!.routineTime;
      _notesController.text = widget.routineEntry!.notes ?? '';
      _skinConditionController.text = widget.routineEntry!.skinCondition ?? '';
      
      // Initialize steps
      for (var step in widget.routineEntry!.steps) {
        _stepControllers.add(TextEditingController(text: step.name));
        _stepIds.add(step.id);
      }
    } else {
      // Creating new routine
      _selectedRoutineTime = RoutineTime.morning;
      _addStep(); // Add one empty step by default
    }
  }

  void _addStep() {
    setState(() {
      _stepControllers.add(TextEditingController());
      _stepIds.add(const Uuid().v4());
    });
  }

  void _removeStep(int index) {
    setState(() {
      _stepControllers[index].dispose();
      _stepControllers.removeAt(index);
      _stepIds.removeAt(index);
    });
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      setState(() {
        _selectedPhotos.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final steps = List.generate(
        _stepControllers.length,
        (index) => RoutineStep(
          id: _stepIds[index],
          name: _stepControllers[index].text.trim(),
          completed: false,
        ),
      );

      if (widget.routineEntry == null) {
        // Create new routine
        await ref.read(routineNotifierProvider.notifier).createRoutineEntry(
          routineTime: _selectedRoutineTime,
          steps: steps,
          notes: _notesController.text.trim(),
          skinCondition: _skinConditionController.text.trim(),
          photos: _selectedPhotos,
        );
      } else {
        // Update existing routine
        await ref.read(routineNotifierProvider.notifier).updateRoutineEntry(
          widget.routineEntry!.id,
          steps: steps,
          notes: _notesController.text.trim(),
          skinCondition: _skinConditionController.text.trim(),
          newPhotos: _selectedPhotos,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    _notesController.dispose();
    _skinConditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routineEntry == null ? 'Add Routine' : 'Edit Routine'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Routine Time Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Routine Time',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<RoutineTime>(
                      segments: const [
                        ButtonSegment(
                          value: RoutineTime.morning,
                          label: Text('Morning'),
                          icon: Icon(Icons.wb_sunny),
                        ),
                        ButtonSegment(
                          value: RoutineTime.evening,
                          label: Text('Evening'),
                          icon: Icon(Icons.nightlight_round),
                        ),
                      ],
                      selected: {_selectedRoutineTime},
                      onSelectionChanged: (Set<RoutineTime> selected) {
                        setState(() {
                          _selectedRoutineTime = selected.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Routine Steps
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Routine Steps',
                          style: theme.textTheme.titleMedium,
                        ),
                        IconButton.filled(
                          onPressed: _addStep,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _stepControllers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _stepControllers[index],
                                  decoration: InputDecoration(
                                    labelText: 'Step ${index + 1}',
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a step';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                                onPressed: () => _removeStep(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes and Skin Condition
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Information',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _skinConditionController,
                      decoration: const InputDecoration(
                        labelText: 'Skin Condition',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Photo Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Photos',
                          style: theme.textTheme.titleMedium,
                        ),
                        IconButton.filled(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_selectedPhotos.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedPhotos.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedPhotos[index],
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _removePhoto(index),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton(
            onPressed: _isLoading ? null : _saveRoutine,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.routineEntry == null ? 'Create Routine' : 'Update Routine',
                  ),
          ),
        ),
      ),
    );
  }
}
