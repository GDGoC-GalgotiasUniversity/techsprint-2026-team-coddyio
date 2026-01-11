import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'ai_chat_screen.dart';
import 'plant_disease_screen.dart';
import 'voice_agent_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const AiChatScreen(sensorData: null),
    const PlantDiseaseScreen(),
    const VoiceAgentScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.nature), label: 'Disease'),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Voice'),
        ],
      ),
    );
  }
}
