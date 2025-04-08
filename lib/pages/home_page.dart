import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'form_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userData = {
        'name': prefs.getString('name') ?? '',
        'age': prefs.getInt('age') ?? 0,
        'income': prefs.getInt('income') ?? 0,
        'hasDebt': prefs.getBool('hasDebt') ?? false,
        'debtAmount': prefs.getInt('debtAmount') ?? 0,
        'debtInterest': prefs.getInt('debtInterest') ?? 0,
        'debtMonthly': prefs.getInt('debtMonthly') ?? 0,
        'food': prefs.getInt('food') ?? 0,
        'clothes': prefs.getInt('clothes') ?? 0,
        'subs': prefs.getInt('subs') ?? 0,
        'otherExpense': prefs.getString('otherExpense') ?? '',
        'water': prefs.getInt('water') ?? 0,
        'electricity': prefs.getInt('electricity') ?? 0,
        'rent': prefs.getInt('rent') ?? 0,
        'phone': prefs.getInt('phone') ?? 0,
        'otherBill': prefs.getString('otherBill') ?? '',
      };
    });
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
              _loadUserData(); // Refresh data when returning
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
                      _infoRow("Other", userData['otherExpense']),
                    ]),
                    _buildSection("Monthly Bills", [
                      _infoRow("Water", "\$${userData['water']}"),
                      _infoRow("Electricity", "\$${userData['electricity']}"),
                      _infoRow("Rent", "\$${userData['rent']}"),
                      _infoRow("Phone", "\$${userData['phone']}"),
                      _infoRow("Other", userData['otherBill']),
                    ]),
                  ],
                ),
      ),
    );
  }
}
