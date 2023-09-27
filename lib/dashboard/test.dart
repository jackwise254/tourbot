import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

const BASE_URL = 'http://10.0.2.2:8000/';
const CHATBOT_ENDPOINT = '${BASE_URL}api/chatbot/';
const CSRF_ENDPOINT = '${BASE_URL}get-csrf/';

void main() => runApp(ChatApp());

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gideon',
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
  bool isBotTyping = false;
  List<String> messages = [];
  TextEditingController messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Widget buildTypingAnimation() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: Card(
            elevation: 0.1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.black87, width: 1.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  CircleAvatar(backgroundImage: AssetImage('assets/bot.png')),
                  SizedBox(width: 10),
                  Text('Gideon is typing...', style: TextStyle(fontSize: 16, color: Colors.black87)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, double>?> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return null;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
  }

  Future<void> _sendMessage() async {
    final userMessage = messageController.text;
    if (userMessage.isEmpty) return;

    HapticFeedback.lightImpact();

    setState(() {
      messages.add("User: $userMessage");
      isBotTyping = true;
    });

    try {
      final csrfToken = await _fetchCsrfToken();
      final userLocation = await _getUserLocation();

      if (csrfToken != null && userLocation != null) {
        final response = await http.post(
          Uri.parse(CHATBOT_ENDPOINT),
          headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': csrfToken,
          },
          body: json.encode({
            'message': userMessage,
            'location': userLocation,
          }),
        );

        if (response.statusCode == 200) {
          await Future.delayed(Duration(seconds: 1));
          final responseData = json.decode(response.body);
          final botMessage = responseData['response'];

          setState(() {
            isBotTyping = false;
            messages.add("Bot: $botMessage");
          });
        } else {
          _handleError("Sorry, I couldn't process your request.");
        }
      } else {
        _handleError("Location or CSRF token missing.");
      }
    } catch (error) {
      _handleError("An error occurred: $error");
    }

    messageController.clear();
    _scrollToBottom();
  }

  void _handleError(String errorMessage) {
    setState(() {
      isBotTyping = false;
      messages.add("Bot: $errorMessage");
    });
  }

  Future<String?> _fetchCsrfToken() async {
    try {
      final response = await http.get(Uri.parse(CSRF_ENDPOINT));
      if (response.statusCode == 200) {
        final cookies = response.headers['set-cookie'];
        final matches = RegExp(r"csrftoken=(.*?);").firstMatch(cookies!);
        return matches?.group(1);
      }
    } catch (error) {
      print("Error fetching CSRF token: $error");
    }
    return null;
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gideon')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[100]!, Colors.orange[50]!],
          ),
          image: DecorationImage(image: AssetImage('assets/back.png'), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: isBotTyping ? messages.length + 1 : messages.length,
                itemBuilder: (context, index) {
                  if (index == messages.length) {
                    return buildTypingAnimation();
                  }
                  bool isUserMessage = messages[index].startsWith('User:');
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        child: Card(
                          elevation: 0.1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: isUserMessage ? BorderSide(color: Colors.orange, width: 1.0) : BorderSide(color: Colors.black87, width: 1.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(messages[index].replaceFirst('User: ', '').replaceFirst('Bot: ', ''), style: TextStyle(fontSize: 16, color: Colors.black87)),
                          ),
                        ),
                      ),
                    ),
                  );
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      onChanged: (text) {
                        setState(() {});  // Trigger a rebuild to refresh the IconButton's onPressed state
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: messageController.text.trim().isEmpty ? null : _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
