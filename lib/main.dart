import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/summary_page.dart';
import 'pages/chat_page.dart';
import 'pages/form_page.dart'; // For edit navigation

void main() {
  runApp(FinanceAIApp());
}

class FinanceAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance AI',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [HomePage(), SummaryPage(), ChatPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Summary'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'FinanceChat'),
        ],
      ),
    );
  }
}
