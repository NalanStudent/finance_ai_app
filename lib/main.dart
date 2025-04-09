import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/summary_page.dart';
import 'pages/chat_page.dart';
import 'pages/expense_track_page.dart'; // <-- NEW IMPORT
import 'pages/form_page.dart'; // For edit navigation

void main() {
  runApp(FinanceAIApp());
}

class FinanceAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

  final List<Widget> _screens = [
    HomePage(),
    SummaryPage(),
    ChatPage(),
    ExpenseTrackPage(), // <-- NEW PAGE
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed, // allows more than 3 items
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Summary'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'FinanceChat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Expenses',
          ), // <-- NEW ITEM
        ],
      ),
    );
  }
}
