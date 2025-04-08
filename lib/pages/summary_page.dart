import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SummaryPage extends StatefulWidget {
  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  String summary = '';
  bool isLoading = false;

  Future<void> generateSummary() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    // Fetch all data
    final userData = {
      'Name': prefs.getString('name') ?? '',
      'Age': prefs.getInt('age') ?? 0,
      'Monthly Income': prefs.getInt('income') ?? 0,
      'Has Debt': prefs.getBool('hasDebt') ?? false,
      'Debt Amount': prefs.getInt('debtAmount') ?? 0,
      'Debt Interest': prefs.getInt('debtInterest') ?? 0,
      'Debt Monthly': prefs.getInt('debtMonthly') ?? 0,
      'Food': prefs.getInt('food') ?? 0,
      'Clothes': prefs.getInt('clothes') ?? 0,
      'Subscriptions': prefs.getInt('subs') ?? 0,
      'Other Expenses': prefs.getString('otherExpense') ?? '',
      'Water Bill': prefs.getInt('water') ?? 0,
      'Electricity': prefs.getInt('electricity') ?? 0,
      'Rent': prefs.getInt('rent') ?? 0,
      'Phone Bill': prefs.getInt('phone') ?? 0,
      'Other Bills': prefs.getString('otherBill') ?? '',
    };

    // Prompt to send to Gemini
    final prompt = """
You are a professional financial advisor. Based on the following financial data, provide a clear and simple summary with the following sections:

1. Financial Health Summary: Provide a brief summary of the individual's overall financial health in one or two sentences.
2. Expense Reduction: Suggest 2-3 specific ways to reduce expenses in a simple and actionable manner.
3. Debt Advice: If applicable, provide one or two pieces of advice on managing or reducing debt effectively.
4. Money Management Tip: Offer one clear, simple tip to improve money management and financial stability.

Ensure that the response is concise, clear, and easy to understand for a user without prior financial knowledge. Focus on practical advice and avoid technical jargon.

Data:
${jsonEncode(userData)}


Follow the structuter below only for output:

Name: [Name]
Age: [Age]
Date: [Date]

Financial Health Summary:
[Summary]

Expense Reduction:
[Reduction]

Dept Advice:
[Advice]

Money Management Tip:
[Tip]

""";

    // Gemini API
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyBIXOs9PJQlPzXP4EFmbWvNPMswzn3mHM4",
    );

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt},
          ],
        },
      ],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final decoded = json.decode(response.body);

      final text = decoded['candidates'][0]['content']['parts'][0]['text'];

      // Remove asterisks from the text (if any)
      String cleanText = text.replaceAll('*', '');

      setState(() {
        summary = cleanText;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        summary = "Failed to generate summary: $e";
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    generateSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Financial Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(child: Text(summary)),
      ),
    );
  }
}
