import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

const BASE_URL = 'http://192.168.0.108:8000/';
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
  // ... Your existing state variables and methods ...

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Tourist Services'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Direction'),
            onTap: () {
              // Handle Direction functionality
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Restaurants'),
            onTap: () {
              // Handle Restaurants functionality
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Weather'),
            onTap: () {
              // Handle Weather functionality
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Tourist Attractions'),
            onTap: () {
              // Handle Tourist Attractions functionality
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gideon'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: buildDrawer(),
      body: Container(
        // ... Your existing body code ...
      ),
    );
  }
}
