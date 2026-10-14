import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'overview_tab.dart';
import 'predict_tab.dart';
import 'results_screen.dart';
import 'login_screen.dart';

const Color green = Color(0xFF005C1F);

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userType;

  const HomeScreen({super.key, required this.userName, required this.userType});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [];

  @override
  void initState() {
    super.initState();
    _tabs.addAll([
      OverviewTab(),
      const PredictTab(),
      const ResultsScreen(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: green,
        title: Text(
          "AgriPredict",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(widget.userName,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text(widget.userType,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: green,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Overview"),
          BottomNavigationBarItem(icon: Icon(Icons.science), label: "Predict"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Results"),
        ],
      ),
    );
  }
}
