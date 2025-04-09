import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'form_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> userData = {};
  int savings = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final hasDebt = prefs.getBool('hasDebt') ?? false;

    final int income = prefs.getInt('income') ?? 0;
    final int food = prefs.getInt('food') ?? 0;
    final int clothes = prefs.getInt('clothes') ?? 0;
    final int subs = prefs.getInt('subs') ?? 0;
    final int water = prefs.getInt('water') ?? 0;
    final int electricity = prefs.getInt('electricity') ?? 0;
    final int rent = prefs.getInt('rent') ?? 0;
    final int phone = prefs.getInt('phone') ?? 0;
    final int debtMonthly = hasDebt ? prefs.getInt('debtMonthly') ?? 0 : 0;

    // Load and sum tracked daily expenses for current month
    final String expensesData = prefs.getString('extraExpenses') ?? '{}';
    final Map<String, dynamic> allTrackedExpenses = json.decode(expensesData);
    final now = DateTime.now();
    int trackedMonthlyTotal = 0;

    allTrackedExpenses.forEach((key, value) {
      final dateParts = key.split('-').map(int.parse).toList(); // yyyy-mm-dd
      if (dateParts.length == 3) {
        final date = DateTime(dateParts[0], dateParts[1], dateParts[2]);
        if (date.year == now.year && date.month == now.month) {
          final List items = value;
          for (var item in items) {
            trackedMonthlyTotal += (item['amount'] as num?)?.toInt() ?? 0;
          }
        }
      }
    });

    final int totalExpenses =
        food +
        clothes +
        subs +
        water +
        electricity +
        rent +
        phone +
        trackedMonthlyTotal;
    final int calculatedSavings = income - totalExpenses - debtMonthly;

    setState(() {
      userData = {
        'name': prefs.getString('name') ?? '',
        'age': prefs.getInt('age') ?? 0,
        'income': income,
        'hasDebt': hasDebt,
        'debtAmount': prefs.getInt('debtAmount') ?? 0,
        'debtInterest': prefs.getInt('debtInterest') ?? 0,
        'debtMonthly': prefs.getInt('debtMonthly') ?? 0,
        'food': food,
        'clothes': clothes,
        'subs': subs,
        'otherExpense': prefs.getString('otherExpense') ?? '',
        'water': water,
        'electricity': electricity,
        'rent': rent,
        'phone': phone,
        'otherBill': prefs.getString('otherBill') ?? '',
        'dailyTrackedExpenses': trackedMonthlyTotal,
      };
      savings = calculatedSavings;
    });
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    return DateFormat('EEE, d MMM yyyy hh:mm a').format(now);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSavingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Card(
        color:
            savings >= 0
                ? const Color.fromARGB(255, 82, 189, 157)
                : const Color.fromARGB(255, 212, 124, 133),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "💰 Estimated Monthly Savings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "\$${savings >= 0 ? savings : 0}",
                style: TextStyle(
                  fontSize: 24,
                  color:
                      savings >= 0
                          ? const Color.fromARGB(255, 11, 40, 16)
                          : const Color.fromARGB(255, 65, 21, 21),
                ),
              ),
              if (savings < 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "You're spending more than you earn!",
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieSections(Map<String, dynamic> data) {
    final income = data['income'] ?? 0;
    final expenses =
        (data['food'] ?? 0) +
        (data['clothes'] ?? 0) +
        (data['subs'] ?? 0) +
        (data['dailyTrackedExpenses'] ?? 0);
    final bills =
        (data['water'] ?? 0) +
        (data['electricity'] ?? 0) +
        (data['rent'] ?? 0) +
        (data['phone'] ?? 0);
    final debt = data['hasDebt'] ? (data['debtMonthly'] ?? 0) : 0;
    final totalSpent = expenses + bills + debt;
    final remaining = (income - totalSpent).clamp(0, income);

    return [
      PieChartSectionData(
        color: Colors.blue,
        value: expenses.toDouble(),
        title: 'Expenses',
        radius: 50,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: bills.toDouble(),
        title: 'Bills',
        radius: 50,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: debt.toDouble(),
        title: 'Debt',
        radius: 50,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: remaining.toDouble(),
        title: 'Savings',
        radius: 50,
        titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Finance Overview"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FormPage()),
              );
              _loadUserData();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child:
            userData.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          "Today: ${_getCurrentDateTime()}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "Budget Breakdown",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    AspectRatio(
                      aspectRatio: 1.3,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: _getPieSections(userData),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildSection("Personal Information", [
                      _infoRow("Name", userData['name']),
                      _infoRow("Age", userData['age']),
                    ]),
                    _buildSection("Monthly Income", [
                      _infoRow("Income", "\$${userData['income']}"),
                    ]),
                    if (userData['hasDebt'])
                      _buildSection("Debt Details", [
                        _infoRow("Total Debt", "\$${userData['debtAmount']}"),
                        _infoRow(
                          "Interest Rate",
                          "${userData['debtInterest']}%",
                        ),
                        _infoRow(
                          "Monthly Payment",
                          "\$${userData['debtMonthly']}",
                        ),
                      ]),
                    _buildSection("Monthly Expenses", [
                      _infoRow("Food", "\$${userData['food']}"),
                      _infoRow("Clothes", "\$${userData['clothes']}"),
                      _infoRow("Subscriptions", "\$${userData['subs']}"),
                      _infoRow(
                        "Daily Tracked Expenses",
                        "\$${userData['dailyTrackedExpenses']}",
                      ),
                      _infoRow("Other", userData['otherExpense']),
                    ]),
                    _buildSection("Monthly Bills", [
                      _infoRow("Water", "\$${userData['water']}"),
                      _infoRow("Electricity", "\$${userData['electricity']}"),
                      _infoRow("Rent", "\$${userData['rent']}"),
                      _infoRow("Phone", "\$${userData['phone']}"),
                      _infoRow("Other", userData['otherBill']),
                    ]),
                    _buildSavingsSection(),
                  ],
                ),
      ),
    );
  }
}
