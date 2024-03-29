import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

const BASE_URL = 'http://192.168.100.31:8000/';
const CHATBOT_ENDPOINT = '${BASE_URL}api/chatbot/';
const CSRF_ENDPOINT = '${BASE_URL}get-csrf/';
// /home/jack/Android/Sdk/flutter
void main() => runApp(ChatApp());

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,

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
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 15.0, right: 15.0),
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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/bot.png'),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Gideon is typing...',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
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
    
    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Could potentially show a dialog to the user to manually enable it.
      return null;
    }

    // Check location permissions.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return null;
      }
    }

    // If all permissions are granted, get the location.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
  }

  Future<void> _sendMessage() async {
    final userMessage = messageController.text;
    if (userMessage.isEmpty) return;

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
        _handleError("Sorry, I couldn't process your request, servers down!.");
      }
    } catch (error) {
      _handleError("An error occurred: $error");
    }

    messageController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gideon')),
      backgroundColor: Colors.orange,

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/back.png'),
              fit: BoxFit.cover,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ Colors.orange[100]!, Colors.orange[50]!],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: isBotTyping ? messages.length + 1 : messages.length,
                itemBuilder: (context, index) {
                  // Check if we should show typing animation
                  if (isBotTyping && index == messages.length) {
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isUserMessage) CircleAvatar(backgroundImage: AssetImage('assets/bot.png')),
                                if (!isUserMessage) SizedBox(width: 10),
                                Expanded(child: Text(messages[index].replaceFirst('User: ', '').replaceFirst('Bot: ', ''), style: TextStyle(fontSize: 16, color: Colors.black87))),
                                if (isUserMessage) SizedBox(width: 10),
                                if (isUserMessage) CircleAvatar(backgroundImage: AssetImage('assets/user.png')),
                              ],
                            ),
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
                  SizedBox(width: 10),
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
      ),
    );
  }
}
