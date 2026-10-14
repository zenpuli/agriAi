import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color green = Color(0xFF005C1F);

class PredictTab extends StatefulWidget {
  const PredictTab({super.key});

  @override
  State<PredictTab> createState() => _PredictTabState();
}

class _PredictTabState extends State<PredictTab> {
  final TextEditingController _cropController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();

  bool _isLoading = false;
  String? _result;

  Future<void> _predictYield() async {
    final crop = _cropController.text.trim();
    final temp = double.tryParse(_temperatureController.text.trim());
    final rain = double.tryParse(_rainfallController.text.trim());

    if (crop.isEmpty || temp == null || rain == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      // 🌾 Simple mock prediction logic (can be replaced with your AI model)
      double predictedYield = (temp * 0.3 + rain * 0.7) / 2;
      String prediction =
          "Predicted yield for $crop is ${predictedYield.toStringAsFixed(2)} tons/acre.";

      // Save prediction to Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('predictions')
            .add({
          'crop': crop,
          'temperature': temp,
          'rainfall': rain,
          'predictedYield': predictedYield,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      setState(() {
        _result = prediction;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Predict"),
        backgroundColor: green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Crop Yield Prediction",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _cropController,
              decoration: const InputDecoration(
                labelText: "Crop Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _temperatureController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Temperature (°C)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rainfallController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Rainfall (mm)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _isLoading ? null : _predictYield,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : const Text("Predict Yield"),
              ),
            ),

            const SizedBox(height: 30),
            if (_result != null)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _result!,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
