// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_workout_screen.dart';
import 'workout_detail_screen.dart'; // We will create this file next

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workout Templates'), // Updated title
        backgroundColor: Colors.blue[800],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // UPDATED: Listen to the 'workout_templates' collection
        stream: FirebaseFirestore.instance
            .collection('workout_templates')
            .orderBy('createdAt', descending: true) // UPDATED: order by creation time
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No workout templates found. Add one!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final templates = snapshot.data!.docs;

          return ListView.builder(
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final templateDoc = templates[index];
              final data = templateDoc.data() as Map<String, dynamic>;
              
              // UPDATED: Use the new field names
              final String exerciseName = data['exerciseName'] ?? 'No Name';
              final int sets = data['targetSets'] ?? 0;
              final int reps = data['targetReps'] ?? 0;
              final double weight = data['targetWeight'] ?? 0.0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    exerciseName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Target: $sets sets of $reps reps @ $weight'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  // NEW: Add onTap for navigation
                  onTap: () {
                    // Navigate to the detail screen, passing the document ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutDetailScreen(
                          templateId: templateDoc.id, // Pass the ID here
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWorkoutScreen()),
          );
        },
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add),
      ),
    );
  }
}