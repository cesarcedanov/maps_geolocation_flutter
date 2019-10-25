import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

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
  CameraPosition _cameraPosition;
  Location _userCurrentLocation = Location();

  Firestore _firestore = Firestore.instance;
  Geoflutterfire _geoflutterfire = Geoflutterfire();

  BehaviorSubject<double> radius = BehaviorSubject.seeded(100);
  Stream<dynamic> query;

  StreamSubscription subscription;

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
  void dispose() {
    // TODO: implement dispose
    subscription.cancel();
    super.dispose();
  }

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
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            onMapCreated: _onMapCreated,
            onLongPress: _newSight,
            onCameraMove: (cameraPosition) {
              setState(() {
                _cameraPosition = cameraPosition;
              });
            },
            markers: Set<Marker>.of(_markers),
          ),
          Positioned(
            bottom: 50,
            right: 10,
            child: FlatButton(
              color: Colors.blue,
              child: Icon(
                Icons.pin_drop,
                color: Colors.white,
              ),
              onPressed: () {
                _newSight(null);
              },
            ),
          ),
          Positioned(
            top: 10,
            left: -10,
            child: FlatButton(
              child: Icon(
                Icons.my_location,
                color: Colors.blue,
              ),
              onPressed: _animateToUser,
            ),
          ),
          Positioned(
            bottom: 50,
            left: 10,
            child: Slider(
              min: 10,
              max: 100,
              // divisions: 4,
              value: radius.value,
              label: 'Radius ${radius.value}km',
              activeColor: Colors.blueGrey,
              inactiveColor: Colors.blueGrey.withOpacity(0.5),
              onChanged: _updateQuery,
            ),
          )
        ],
      ),
    );
  }

  void _newSight(LatLng pickedPosition) async {
    LatLng position = pickedPosition ?? _cameraPosition.target;
    await Navigator.of(context)
        .push(
      MaterialPageRoute(builder: (ctx) => NewSightScreen()),
    )
        .then((markerOpts) async {
      if (markerOpts != null) {
        try {
          _addMarker(position, markerOpts);
          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: position,
                zoom: 17,
              ),
            ),
          );
          _addGeoPoint(position, markerOpts);
        } catch (error) {
          print(error);
        }
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Error ocurred saving the Location'),
            content: Text('Invalid data'),
          ),
        );
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
    _startQuery();
    setState(() {
      _mapController = controller;
    });
  }

  Future<void> _goToTheBlueMall() async {
    // final GoogleMapController controller = await _mapController.future;
    _mapController.animateCamera(CameraUpdate.newCameraPosition(_kBlueMall));
  }

  _animateToUser() async {
    var userCurrentLocation = await _userCurrentLocation.getLocation();
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            userCurrentLocation.latitude,
            userCurrentLocation.longitude,
          ),
          zoom: 17,
        ),
      ),
    );
  }

  Future<DocumentReference> _addGeoPoint(
      LatLng position, Map<String, String> markerOpts) async {
    GeoFirePoint point = _geoflutterfire.point(
        latitude: position.latitude, longitude: position.longitude);

    return _firestore.collection('locations').add({
      'position': point.data,
      'title': markerOpts['title'],
      'description': markerOpts['snippet'],
    });
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    print(documentList);
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint point = document.data['position']['geopoint'];
      double distance = document.data['distance'];
      var marker = Marker(
        position: LatLng(point.latitude, point.longitude),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: 'Dummy Marker',
          snippet: '$distance km from query center',
        ),
      );
      _markers.add(marker);
    });
  }

  _startQuery() async {
    var pos = await _userCurrentLocation.getLocation();

    var refLocations = _firestore.collection('locations');
    GeoFirePoint center =
        _geoflutterfire.point(latitude: pos.latitude, longitude: pos.longitude);

    subscription = radius.switchMap((rad) {
      return _geoflutterfire.collection(collectionRef: refLocations).within(
            radius: rad,
            center: center,
            field: 'position',
            strictMode: true,
          );
    }).listen(_updateMarkers);
  }

  _updateQuery(value) {
    double zoom;

    if (value <= 10) {
      zoom = 18.0;
    } else if (value > 10 && value <= 25) {
      zoom = 16.0;
    } else if (value > 25 && value <= 50) {
      zoom = 13.0;
    } else if (value > 50 && value <= 75) {
      zoom = 12.0;
    } else {
      zoom = 10;
    }

    _mapController.moveCamera(CameraUpdate.zoomTo(zoom));
    setState(() {
      radius.add(value);
    });
  }
}
