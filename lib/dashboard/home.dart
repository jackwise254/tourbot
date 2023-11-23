import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat.dart';

void main() => runApp(MainDashboardPage());

class MainDashboardPage extends StatefulWidget {
  @override
  _MainDashboardPageState createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {
  LatLng? userLocation;
  List<LatLng> pois = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  void _onAndroidIconPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatPage()),
    );
  }

  Future<void> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    userLocation = LatLng(position.latitude, position.longitude);
    pois = await fetchPOIs(userLocation!);
    setState(() {});
  }

  Future<List<LatLng>> fetchPOIs(LatLng center) async {
    final query = '''
      [out:json][timeout:25];
      (
        node["tourism"="museum"](${center.latitude - 0.1},${center.longitude - 0.1},${center.latitude + 0.1},${center.longitude + 0.1});
        node["tourism"="attraction"](${center.latitude - 0.1},${center.longitude - 0.1},${center.latitude + 0.1},${center.longitude + 0.1});
      );
      out body;
    ''';

    final response = await http.get(
        Uri.parse('https://overpass-api.de/api/interpreter?data=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<LatLng> fetchedPOIs = [];
      for (var element in data['elements']) {
        fetchedPOIs.add(LatLng(element['lat'], element['lon']));
      }
      return fetchedPOIs;
    } else {
      throw Exception('Failed to fetch POIs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryTextTheme: TextTheme(
          headline6: TextStyle(color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(2.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TabBar(
                    indicatorColor: Colors.grey,
                    labelPadding: EdgeInsets.only(top: 2.0),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home, color: Colors.white),
                            SizedBox(width: 8),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time, color: Colors.white),
                            SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/logo.png'),
                      radius: 16.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search for places...',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.mic),
                            color: Colors.grey,
                            onPressed: () {
                              // Logic to trigger voice search
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                 
                Container(
                  height: 200.0,
                  child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5, // Number of rectangles
                    itemBuilder: (context, index) {
                      final int pageIndex = index % 5; // Calculate the actual index in a loop
                      return Container(
                        width: 150.0,
                        margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: AssetImage('assets/bot.png'), // Change to your image
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0),
                                ),
                              ),
                              child: Text(
                                'Tourist Site $pageIndex',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),


                Expanded(
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Colors.orange, // You can change the color as needed
                          width: 2.0,
                        ),
                      ),


                      child: FlutterMap(
                        options: MapOptions(
                            center: userLocation,
                            zoom: 13.0,
                          ),
                        children: [
                          TileLayer(
                             urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: ['a', 'b', 'c'],
                          ),
                          // Add other layers as needed
                        ],
                      ),



                      
                    ),
                  ),
                ],
              ),
              Center(child: Text("Recent Tab")),
            ],
          ),








          
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatPage()),
                );
              }
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 25.0), label: ""),
              BottomNavigationBarItem(
                  icon: Icon(Icons.android, size: 25.0), label: ""),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings_input_antenna, size: 25.0),
                  label: ""),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications, size: 25.0), label: ""),
            ],
            backgroundColor: Colors.orange,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
          ),
        ),
      ),
    );
  }
}
