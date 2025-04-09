import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class SummaryPage extends StatefulWidget {
  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  String summary = '';
  bool isLoading = false;
  String currentDate = '';

  String _getCurrentDateTime() {
    final now = DateTime.now();
    return DateFormat('EEE, d MMM yyyy hh:mm a').format(now);
  }

  Future<void> generateSummary() async {
    setState(() {
      isLoading = true;
      currentDate = _getCurrentDateTime();
    });

    final prefs = await SharedPreferences.getInstance();

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

    final prompt = """
You are a professional financial advisor. Based on the following financial data, provide a clear and simple summary with the following sections:

1. Financial Health Summary: Provide a brief summary of the individual's overall financial health in one or two sentences.
2. Expense Reduction: Suggest 2-3 specific ways to reduce expenses in a simple and actionable manner.
3. Debt Advice: If applicable, provide one or two pieces of advice on managing or reducing debt effectively.
4. Money Management Tip: Offer one clear, simple tip to improve money management and financial stability.

Ensure that the response is concise, clear, and easy to understand for a user without prior financial knowledge. Focus on practical advice and avoid technical jargon.

Data:
${jsonEncode(userData)}

Follow the structure below only for output without additional starting or ending text:

Name: [Name]
Age: [Age]

Financial Health Summary:
[Summary in small brief paragraph]

Expense Reduction:
[Reduction in small brief paragraph]

Dept Advice:
[Advice in small brief paragraph]

Money Management Tip:
[Tip in small brief paragraph]
""";

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

  Future<void> _exportSummaryAsPDF(String summaryText) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Padding(
              padding: pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "AI Financial Summary",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    currentDate,
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColor.fromInt(0xFF666666),
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(summaryText, style: pw.TextStyle(fontSize: 14)),
                ],
              ),
            ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
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
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Your AI-Powered Financial Summary",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    if (currentDate.isNotEmpty)
                      Text(
                        "Generated on: $currentDate",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(summary, style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text("Download as PDF"),
                      onPressed: () {
                        if (summary.isNotEmpty) {
                          _exportSummaryAsPDF(summary);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("No summary to export.")),
                          );
                        }
                      },
                    ),
                  ],
                ),
      ),
    );
  }
}
