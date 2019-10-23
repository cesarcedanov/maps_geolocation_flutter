import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_geolocation/new_sight_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  GoogleMapController _mapController;
  List<Marker> _markers = [];

  static final CameraPosition _kAgoraMall = CameraPosition(
    target: LatLng(18.4835421, -69.9398128),
    zoom: 17,
  );

  static final CameraPosition _kBlueMall = CameraPosition(
      bearing: 45.8334901395799,
      target: LatLng(18.47258932432269, -69.94110390543938),
      tilt: 9.440717697143555,
      zoom: 17.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Maps with Geolocation'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: _kAgoraMall,
            mapType: MapType.normal,
            onMapCreated: _onMapCreated,
            onLongPress: _newSight,
            markers: Set<Marker>.of(_markers),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheBlueMall,
        label: Text('Take me to Blue Mall'),
        icon: Icon(Icons.local_mall),
      ),
    );
  }

  void _newSight(LatLng position) {
    print(position);
    Navigator.of(context)
        .push(
      MaterialPageRoute(builder: (ctx) => NewSightScreen()),
    )
        .then((markerOpts) {
      if (markerOpts != null) {
        _addMarker(position, markerOpts);
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: position,
              zoom: 17,
            ),
          ),
        );
      } else {
        print(markerOpts);
      }
    });
  }

  _addMarker(LatLng position, Map<String, String> markerOpts) {
    List<Marker> tempMarkers = _markers;
    tempMarkers.add(
      Marker(
        markerId: MarkerId(DateTime.now().toString()),
        position: position,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
            title: markerOpts['title'], snippet: markerOpts['snippet']),
        draggable: true,
        // onTap: () {},
      ),
    );

    setState(() {
      _markers = tempMarkers;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  Future<void> _goToTheBlueMall() async {
    // final GoogleMapController controller = await _mapController.future;
    _mapController.animateCamera(CameraUpdate.newCameraPosition(_kBlueMall));
  }
}
