import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _incomeController = TextEditingController();
  final _foodController = TextEditingController();
  final _clothesController = TextEditingController();
  final _subsController = TextEditingController();
  final _otherExpController = TextEditingController();
  final _waterController = TextEditingController();
  final _electricController = TextEditingController();
  final _rentController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otherBillController = TextEditingController();
  final _debtAmountController = TextEditingController();
  final _debtInterestController = TextEditingController();
  final _debtMonthlyController = TextEditingController();

  bool _hasDebt = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _incomeController.dispose();
    _foodController.dispose();
    _clothesController.dispose();
    _subsController.dispose();
    _otherExpController.dispose();
    _waterController.dispose();
    _electricController.dispose();
    _rentController.dispose();
    _phoneController.dispose();
    _otherBillController.dispose();
    _debtAmountController.dispose();
    _debtInterestController.dispose();
    _debtMonthlyController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', _nameController.text);
    await prefs.setInt('age', int.tryParse(_ageController.text) ?? 0);
    await prefs.setInt('income', int.tryParse(_incomeController.text) ?? 0);
    await prefs.setBool('hasDebt', _hasDebt);

    if (_hasDebt) {
      await prefs.setInt(
        'debtAmount',
        int.tryParse(_debtAmountController.text) ?? 0,
      );
      await prefs.setInt(
        'debtInterest',
        int.tryParse(_debtInterestController.text) ?? 0,
      );
      await prefs.setInt(
        'debtMonthly',
        int.tryParse(_debtMonthlyController.text) ?? 0,
      );
    }

    await prefs.setInt('food', int.tryParse(_foodController.text) ?? 0);
    await prefs.setInt('clothes', int.tryParse(_clothesController.text) ?? 0);
    await prefs.setInt('subs', int.tryParse(_subsController.text) ?? 0);
    await prefs.setString('otherExpense', _otherExpController.text);

    await prefs.setInt('water', int.tryParse(_waterController.text) ?? 0);
    await prefs.setInt(
      'electricity',
      int.tryParse(_electricController.text) ?? 0,
    );
    await prefs.setInt('rent', int.tryParse(_rentController.text) ?? 0);
    await prefs.setInt('phone', int.tryParse(_phoneController.text) ?? 0);
    await prefs.setString('otherBill', _otherBillController.text);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Data saved!")));
    Navigator.pop(context);
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Personal Info",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              _buildTextField("Name", _nameController),
              _buildTextField(
                "Age",
                _ageController,
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 16),
              Text(
                "Finance Info",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              _buildTextField(
                "Monthly Income",
                _incomeController,
                keyboardType: TextInputType.number,
              ),

              SwitchListTile(
                title: Text("Do you have debt?"),
                value: _hasDebt,
                onChanged: (val) => setState(() => _hasDebt = val),
              ),

              if (_hasDebt) ...[
                _buildTextField(
                  "Total Debt",
                  _debtAmountController,
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  "Debt Interest Rate (%)",
                  _debtInterestController,
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  "Monthly Debt Payment",
                  _debtMonthlyController,
                  keyboardType: TextInputType.number,
                ),
              ],

              SizedBox(height: 16),
              Text(
                "Monthly Expenses",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              _buildTextField(
                "Food",
                _foodController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                "Clothes",
                _clothesController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                "Subscriptions",
                _subsController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField("Other Expenses", _otherExpController),

              SizedBox(height: 16),
              Text(
                "Monthly Bills",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              _buildTextField(
                "Water Bill",
                _waterController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                "Electricity Bill",
                _electricController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                "Rent",
                _rentController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                "Phone Bill",
                _phoneController,
                keyboardType: TextInputType.number,
              ),
              _buildTextField("Other Bills", _otherBillController),

              SizedBox(height: 24),
              ElevatedButton(onPressed: _saveData, child: Text("Save")),
            ],
          ),
        ),
      ),
    );
  }
}
