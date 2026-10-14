import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color green = Color(0xFF005C1F);

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  Future<void> _clearHistory(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All History"),
        content: const Text(
          "Are you sure you want to delete all prediction history? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Clear"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final predictionsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('predictions');

      final snapshots = await predictionsRef.get();
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }

      // Show confirmation
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("History cleared successfully.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please log in to view results."),
        ),
      );
    }

    final predictionsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('predictions')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: const Text("Results"),
        backgroundColor: green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            tooltip: "Clear History",
            onPressed: () => _clearHistory(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: predictionsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: green));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No prediction history found.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final predictions = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: predictions.length,
            itemBuilder: (context, index) {
              final data = predictions[index].data() as Map<String, dynamic>;
              final crop = data['crop'] ?? 'Unknown';
              final temp = data['temperature'] ?? 0.0;
              final rain = data['rainfall'] ?? 0.0;
              final yieldVal = data['predictedYield'] ?? 0.0;
              final time = (data['timestamp'] as Timestamp?)?.toDate();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    "Crop: $crop",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Temp: ${temp.toStringAsFixed(1)}°C, Rain: ${rain.toStringAsFixed(1)}mm\n"
                    "Yield: ${yieldVal.toStringAsFixed(2)} tons/acre",
                  ),
                  trailing: Text(
                    time != null
                        ? "${time.day}/${time.month}/${time.year}"
                        : "—",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
