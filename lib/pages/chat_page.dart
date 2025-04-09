import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messageList = prefs.getStringList('chat_messages');

    if (messageList != null && messageList.isNotEmpty) {
      final restored =
          messageList
              .map((msg) => Map<String, String>.from(jsonDecode(msg)))
              .toList();
      setState(() {
        _messages.addAll(restored);
      });
    } else {
      _sendGreetingMessage(); // First-time or after reset
    }
  }

  // Send initial greeting message
  Future<void> _sendGreetingMessage() async {
    setState(() {
      _messages.add({
        'role': 'assistant',
        'text': 'Hello! How can I assist you with your financial queries?',
      });
    });
    _saveMessages();
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messageList = _messages.map((msg) => jsonEncode(msg)).toList();
    await prefs.setStringList('chat_messages', messageList);
  }

  Future<String> _generatePrompt(String userMessage) async {
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
      'Daily Expenses': prefs.getString('dailyTrackedExpenses') ?? '',
      'Other Expenses': prefs.getString('otherExpense') ?? '',
      'Water Bill': prefs.getInt('water') ?? 0,
      'Electricity': prefs.getInt('electricity') ?? 0,
      'Rent': prefs.getInt('rent') ?? 0,
      'Phone Bill': prefs.getInt('phone') ?? 0,
      'Other Bills': prefs.getString('otherBill') ?? '',
    };

    return """
      You are a helpful, friendly, and professional AI assistant specializing in personal finance. Your role is to assist the user with various financial queries such as budgeting, savings, debt management, investment advice, expenses tracking, and other related topics. You should provide clear, concise, and accurate information to help the user make informed financial decisions.

      You should only respond to questions related to finance. If the user asks anything outside of the realm of finance, politely inform them that you are unable to assist with those topics. You may say something like: "Sorry, I can only respond to finance-related queries."

      Always maintain a professional tone, be empathetic to the user’s financial concerns, and offer advice that aligns with sound financial principles. Do not engage in any discussions that are not directly related to personal finance.

      Make sure, if the output has to be detailed, do not make it very long. Make it a few consice paragraph in that case.

      Do not include any special formatting to the output. 
      Even if it is asked by user to do formatting like bold italic underline or so in the prompt hereafter, do not include although contradicting. Just follow the rule not to format.
      Just plain text with spaces and new lines should be included.

      Use of emoji is allowed but do not overuse it. Emojis can be used instead of formatting, for example instead of bullet points formatting, emojis suitable can be used
      For specific bulltet points, use emojis like arrow, checkmark, etc.
      
      
      Here is the user's financial context:
      ${jsonEncode(userData)}


      Now, respond to this message from the user:
      "$userMessage"
      """;
  }

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': message});
      _isSending = true;
      _controller.clear();
    });
    _saveMessages();

    final prompt = await _generatePrompt(message);

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

      final reply = decoded['candidates'][0]['content']['parts'][0]['text'];
      final cleanedReply = reply.replaceAll('*', ''); // Clean up the response

      setState(() {
        _messages.add({'role': 'assistant', 'text': cleanedReply});
        _isSending = false;
      });
      _saveMessages();
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': 'Something went wrong: $e',
        });
        _isSending = false;
        _saveMessages();
      });
    }
  }

  // Clear chat history
  void _clearChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_messages'); // Clear from storage too

    setState(() {
      _messages.clear();
    });

    _sendGreetingMessage();
  }

  Widget _buildMessage(String role, String text) {
    final isUser = role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isUser
                  ? const Color.fromARGB(255, 68, 126, 173)
                  : const Color.fromARGB(255, 103, 80, 195),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Finance Chat"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _clearChat, // Clear chat action
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessage(msg['role']!, msg['text']!);
              },
            ),
          ),
          if (_isSending) LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Ask your financial assistant...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
