import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyExpensesPage extends StatefulWidget {
  @override
  State<DailyExpensesPage> createState() => _DailyExpensesPageState();
}

class _DailyExpensesPageState extends State<DailyExpensesPage> {
  Map<String, TextEditingController> expenseControllers = {};
  String selectedDay = '01';
  String selectedMonth = 'January';

  @override
  void initState() {
    super.initState();
    expenseControllers = {
      'food': TextEditingController(),
      'clothes': TextEditingController(),
      'subs': TextEditingController(),
      'water': TextEditingController(),
      'electricity': TextEditingController(),
      'rent': TextEditingController(),
      'phone': TextEditingController(),
      'debtMonthly': TextEditingController(),
    };
  }

  // Save the daily expenses to SharedPreferences
  Future<void> _saveDailyExpenses() async {
    final prefs = await SharedPreferences.getInstance();

    expenseControllers.forEach((key, controller) {
      int expense = int.tryParse(controller.text) ?? 0;
      prefs.setInt('$key-$selectedDay-$selectedMonth', expense);
    });

    Navigator.pop(context); // Return to HomePage after saving
  }

  // Build expense input field
  Widget _buildExpenseField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
      ),
    );
  }

  // Build day selector
  Widget _buildDaySelector() {
    return DropdownButton<String>(
      value: selectedDay,
      onChanged: (String? newDay) {
        setState(() {
          selectedDay = newDay!;
        });
      },
      items:
          List.generate(31, (index) {
            String day = (index + 1).toString().padLeft(2, '0');
            return DropdownMenuItem<String>(value: day, child: Text(day));
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Expenses')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildDaySelector(),
              _buildExpenseField('Food', expenseControllers['food']!),
              _buildExpenseField('Clothes', expenseControllers['clothes']!),
              _buildExpenseField('Subscriptions', expenseControllers['subs']!),
              _buildExpenseField('Water', expenseControllers['water']!),
              _buildExpenseField(
                'Electricity',
                expenseControllers['electricity']!,
              ),
              _buildExpenseField('Rent', expenseControllers['rent']!),
              _buildExpenseField('Phone', expenseControllers['phone']!),
              _buildExpenseField(
                'Debt Monthly',
                expenseControllers['debtMonthly']!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveDailyExpenses,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
