// lib/workout_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

class WorkoutDetailScreen extends StatefulWidget {
  final String templateId;

  const WorkoutDetailScreen({super.key, required this.templateId});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  // A function to handle logging the workout
  Future<void> _logWorkout(Map<String, dynamic> templateData) async {
    try {
      // Add a new document to the 'workout_logs' collection
      await FirebaseFirestore.instance.collection('workout_logs').add({
        'templateId': widget.templateId, // Link to the template
        'completionDate': Timestamp.now(), // Record the current time
        
        // Denormalize (copy) data for easy display in history lists
        'exerciseName': templateData['exerciseName'],
        'targetSets': templateData['targetSets'],
        'targetReps': templateData['targetReps'],
        'targetWeight': templateData['targetWeight'],
        'notes': '', // Add an empty notes field for future use
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout logged successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log workout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
       print('--- Querying for logs with templateId: "${widget.templateId}" ---');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details'),
        backgroundColor: Colors.blue[800],
      ),
      // Use a FutureBuilder to fetch the template data once
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('workout_templates')
            .doc(widget.templateId)
            .get(),
        builder: (context, snapshot) {
          // --- Handle Loading and Error States for Template Data ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Workout template not found.'));
          }
          
          // --- Display Template Data and Log Button ---
          final templateData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the template details in a Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          templateData['exerciseName'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Target: ${templateData['targetSets']} sets of ${templateData['targetReps']} reps @ ${templateData['targetWeight']}',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 24),
                        // The "Log Workout" button
                        ElevatedButton.icon(
                          onPressed: () => _logWorkout(templateData),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Log This Workout'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Completion History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Text(widget.templateId),
                // --- Display Completion History using a StreamBuilder ---
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    // Query the 'workout_logs' for entries matching this template
                    stream: FirebaseFirestore.instance
                        .collection('workout_logs')
                        .where('templateId', isEqualTo: widget.templateId)
                        .orderBy('completionDate', descending: true)
                        .snapshots(),
                    builder: (context, logSnapshot) {
                      if (logSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!logSnapshot.hasData || logSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No logs yet. Complete it!'));
                      }
                      
                      final logs = logSnapshot.data!.docs;

                      // This is the ID the screen is trying to find.
                      final String queriedId = widget.templateId;
                      return ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final logData = logs[index].data() as Map<String, dynamic>;
                        // This is the ID actually stored in the document.
          final String storedId = logData['templateId'] ?? 'ID NOT FOUND';

          // --- PROGRAMMATIC COMPARISON ---
          // 1. We ask Dart if the strings are truly equal.
          final bool areTheyEqual = (queriedId == storedId);

          // 2. We get the length of each string. This is the key to finding whitespace.
          final String comparisonDetails = 
              'Lengths match: ${queriedId.length == storedId.length}. Are equal: $areTheyEqual';

          // 3. We format the date as before.
          final Timestamp completionTimestamp = logData['completionDate'];
          final String formattedDate = DateFormat.yMMMd().format(completionTimestamp.toDate());
  return ListTile(
            // Change the tile color based on the comparison result for clear visual feedback.
            tileColor: areTheyEqual ? Colors.lightGreen[100] : Colors.red[100],
            title: Text('Completed: $formattedDate'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stored ID: "$storedId"'),
                Text(comparisonDetails),
              ],
            ),
          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}