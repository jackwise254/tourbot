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
        desiredAccuracy: LocationAccuracy.high);
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

    final response = await http.get(Uri.parse('https://overpass-api.de/api/interpreter?data=$query'));

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
                    indicatorColor: Colors.white,
                    labelPadding: EdgeInsets.only(top: 2.0),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home, color: Colors.white),
                            SizedBox(width: 8),
                            // Text("Home"),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time, color: Colors.white),
                            SizedBox(width: 8),
                            // Text("Recent"),
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
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
                Expanded(
                  child: userLocation == null
                      ? Center(child: CircularProgressIndicator())
                      : FlutterMap(
                          options: MapOptions(
                            center: userLocation,
                            zoom: 13.0,
                          ),
                          layers: [
                            TileLayerOptions(
                              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: ['a', 'b', 'c'],
                            ),
                            MarkerLayerOptions(
                            markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: userLocation!,
                                builder: (ctx) => Container(
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40.0,
                                  ),
                                ),
                              ),
                              ...pois.map((poi) {
                                return Marker(
                                  width: 80.0,
                                  height: 80.0,
                                  point: poi,
                                  builder: (ctx) => Container(
                                    child: Icon(
                                      Icons.place,
                                      color: Colors.orange,
                                      size: 40.0,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                          ],
                        ),
                ),
              ],
            ),
            Center(child: Text("Recent Tab")), // Placeholder for the Recent Tab
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 1) { // The Android icon is at index 1
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
            BottomNavigationBarItem(icon: Icon(Icons.home, size:25.0), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.android, size:25.0), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.settings_input_antenna, size:25.0), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.notifications, size:25.0), label: ""),
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
