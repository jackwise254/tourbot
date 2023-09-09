import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(ChatApp());

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tourist Assistant Chatbot',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<String> messages = [];
  TextEditingController messageController = TextEditingController();

  Future<void> _sendMessage() async {
    final userMessage = messageController.text;
    if (userMessage.isNotEmpty) {
      final csrfToken = await _fetchCsrfToken();
      if (csrfToken != null) {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/chatbot/'),
          headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': csrfToken,
          },
          body: json.encode({'message': userMessage}),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final botMessage = responseData['response'];
          setState(() {
            messages.add("User: $userMessage");
            messages.add("Bot: $botMessage");
          });
        }
      }
      messageController.clear();
    }
  }

  Future<String?> _fetchCsrfToken() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/get-csrf/'));
    if (response.statusCode == 200) {
      final cookies = response.headers['set-cookie'];
      final matches = RegExp(r"csrftoken=(.*?);").firstMatch(cookies!);
      return matches?.group(1);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tourist Assistant Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(messages[index]));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
