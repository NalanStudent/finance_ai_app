import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExpenseTrackPage extends StatefulWidget {
  @override
  _ExpenseTrackPageState createState() => _ExpenseTrackPageState();
}

class _ExpenseTrackPageState extends State<ExpenseTrackPage> {
  DateTime selectedDate = DateTime.now();
  Map<String, List<Map<String, dynamic>>> expenses = {};

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('extraExpenses') ?? '{}';
    setState(() {
      expenses = Map<String, List<Map<String, dynamic>>>.from(
        json
            .decode(data)
            .map(
              (key, value) => MapEntry(
                key,
                List<Map<String, dynamic>>.from(
                  value.map((e) => Map<String, dynamic>.from(e)),
                ),
              ),
            ),
      );
    });
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('extraExpenses', json.encode(expenses));
  }

  void _addExpense(String title, double amount) {
    final key = _dateKey(selectedDate);
    if (!expenses.containsKey(key)) {
      expenses[key] = [];
    }
    expenses[key]!.add({'title': title, 'amount': amount});
    _saveExpenses();
    setState(() {});
  }

  void _deleteExpense(String key, int index) {
    expenses[key]!.removeAt(index);
    if (expenses[key]!.isEmpty) expenses.remove(key);
    _saveExpenses();
    setState(() {});
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  void _showAddDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Add Expense'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = titleController.text;
                  final amount = double.tryParse(amountController.text) ?? 0;
                  if (title.isNotEmpty && amount > 0) {
                    _addExpense(title, amount);
                    Navigator.pop(context);
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final key = _dateKey(selectedDate);
    final dayExpenses = expenses[key] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Track Daily Expenses"),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) setState(() => selectedDate = date);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Expenses for ${selectedDate.toLocal().toString().split(' ')[0]}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dayExpenses.length,
              itemBuilder: (_, index) {
                final item = dayExpenses[index];
                return ListTile(
                  title: Text(item['title']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("\$${item['amount'].toStringAsFixed(2)}"),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteExpense(key, index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
