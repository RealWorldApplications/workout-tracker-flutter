// lib/add_workout_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  // 1. Create TextEditingController for each text field
  final _exerciseNameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

  // 2. Remember to dispose of the controllers when the widget is removed
  @override
  void dispose() {
    _exerciseNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // 3. The function to save the workout data
  Future<void> _saveWorkout() async {
    // Basic validation to ensure fields are not empty
    if (_exerciseNameController.text.isEmpty ||
        _setsController.text.isEmpty ||
        _repsController.text.isEmpty ||
        _weightController.text.isEmpty) {
      // Optional: Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return; // Stop the function if validation fails
    }

    try {
      // Get a reference to the 'workouts' collection in Firestore
      final collection = FirebaseFirestore.instance.collection('workout_templates');

    // ... inside _saveWorkout()
await collection.add({
  'exerciseName': _exerciseNameController.text,
  'targetSets': int.parse(_setsController.text), // Renamed to targetSets
  'targetReps': int.parse(_repsController.text), // Renamed to targetReps
  'targetWeight': double.parse(_weightController.text), // Renamed to targetWeight
  'createdAt': Timestamp.now(), // Renamed from 'timestamp' for clarity
});
// ...
      // After saving, go back to the previous screen (HomeScreen)
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Optional: Show an error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save workout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Workout'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 4. TextFields for user input
            TextField(
              controller: _exerciseNameController,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _setsController,
              decoration: const InputDecoration(labelText: 'Target Sets'),
              keyboardType: TextInputType.number, // Show number keyboard
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _repsController,
              decoration: const InputDecoration(labelText: 'Target Reps'),
              keyboardType: TextInputType.number, // Show number keyboard
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Target Weight (lbs/kg)'),
              keyboardType: TextInputType.number, // Show number keyboard
            ),
            const SizedBox(height: 32),

            // 5. The Save Button
            ElevatedButton(
              onPressed: _saveWorkout, // Call our save function
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Workout'),
            ),
          ],
        ),
      ),
    );
  }
}