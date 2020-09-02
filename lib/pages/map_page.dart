import 'dart:async';
import 'dart:math';
import 'package:backdrop/global.dart' as global;
import 'package:backdrop/pages/photo_upload_page.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import '../ui/photo_box.dart';
import '../ui/user_photo_box.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geohash/geohash.dart';
import 'package:flutter/services.dart' show rootBundle;

String placeId;
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: global.kGoogleApiKey);
 
class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MapPageState();
  }
}
 
class MapPageState extends State<MapPage> {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController mapController;
  List<PlacesSearchResult> places = [];
  bool isLoading = false;
  String errorMessage;
  bool _pressed = false;
  bool _userBox = false;
  String _placeId;
  String _userBackdropId;
  int radius = 1000;
  Set<Marker> markers = {};
  LatLng _center = LatLng(0,0);
  Set<DocumentSnapshot> userBackdrops = new Set();
  double mapHeightWithBox = .865;
  BitmapDescriptor defaultPin;
  BitmapDescriptor userPin;
  String _mapStyle;

  Geoflutterfire geo = Geoflutterfire();
  var uuid = Uuid();

  //for testing
  LatLng gR = new LatLng(42.9634, -85.6681); 

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
         ImageConfiguration(devicePixelRatio: 2.5),
         'assets/markerBlue.png').then((onValue) {
            defaultPin = onValue;
         });
    BitmapDescriptor.fromAssetImage(
         ImageConfiguration(devicePixelRatio: 2.5),
         'assets/markerPurple.png').then((onValue) {
            userPin = onValue;
         });
    rootBundle.loadString('assets/map_theme.txt').then((string) {
    _mapStyle = string;
  });
  }
 
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    Widget expandedChild;
    if (isLoading && _pressed) {
      expandedChild = Center(child: SpinKitWave(color: global.mainPurple, type: SpinKitWaveType.center));
    } else if (errorMessage != null) {
      expandedChild = Center(
        child: Text(errorMessage),
      );
    } else {
      expandedChild = _pressed 
      ? new Container(color: global.mainPurple)
      : new Container(color: global.mainPurple, height: 0);
    }
 
    return Scaffold(
      key: homeScaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: global.mainPurple,
        title: const Text(
          "Backdrop",
          style: TextStyle(color: Colors.white, fontFamily: "Freight Sans", fontStyle: FontStyle.italic)
          ),
        actions: <Widget>[
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.refresh),
            onPressed: () {
              refresh();
            }
          ),
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.add_a_photo),
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => 
                PhotoUploadPage(
                      location: this._center,
                  )
                )
              );
            },
          ),
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.search),
            onPressed: () {
              _handlePressSearch();
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(            
            height: (MediaQuery.of(context).size.height) * mapHeightWithBox, //Takes up .5714 of display         
            child: GoogleMap(               
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: _center, zoom: 17.0),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: markers             
              ),
            ),
          _pressed 
          ? new Builder(builder: (BuildContext context) { return new PhotoBox(_placeId); }) 
          : _userBox 
            ? new Builder(builder: (BuildContext context) { return new UserPhotoBox(_userBackdropId); })
            : new SizedBox(),
          Expanded(child:Container(color: global.mainPurple))
        ],
      )
    );
  }
 
  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
    refresh();
  }
  
  Future <LatLng> getUserLocation() async {
    final location = LocationManager.Location();
    var currentLocation;
    try {
      currentLocation = await location.getLocation();
      final center = LatLng(currentLocation.latitude, currentLocation.longitude);
      return center;
    } on Exception {
      currentLocation = null;
      return null;
    }
  }

  void refresh() async {
    _center = await getUserLocation();
    //Workaround to fix iOS Google Maps SDK centering issue
    Future.delayed(const Duration(milliseconds: 300));
    mapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 17.0, target: _center)));
    getUserBackdrops(_center);
    getNearbyPlaces(_center);
  }
      
  void getNearbyPlaces(LatLng center) async {
    setState(() {
      this.isLoading = true;
      this.errorMessage = null;
    });

    final location = Location(center.latitude, center.longitude);
    final result = await _places.searchNearbyWithRadius(location, radius);
    
    setState(() {
      this.isLoading = false;
      if (result.status == "OK") {
        this.places = result.results;
        this.places.forEach((f) {
          markers.add(
            Marker(
              markerId: MarkerId(f.placeId),
              icon: defaultPin,
              position: LatLng(f.geometry.location.lat, f.geometry.location.lng),
              infoWindow: InfoWindow (title: f.name),
              onTap: () => showPhotoBox(f.placeId)
            )
          );           
        });
        buildNearbyUserMarkers(userBackdrops).forEach((m) => 
          markers.add(m)
        );
      } else {
        this.errorMessage = result.errorMessage;
      }
    });
  }

  void getUserBackdrops(LatLng userLocation) async {
    //Get list of data from firestore using Fluttergeofire query
    Firestore _firestore = Firestore.instance;
    GeoFirePoint firePoint = geo.point(latitude: userLocation.latitude, longitude: userLocation.longitude);
    var collectionReference = _firestore.collection('backdrops');
    Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: collectionReference)
                                        .within(center: firePoint, radius: 1000, field: 'position');
    await for (var doc in stream) {
      userBackdrops.addAll(doc);
    }
  }

  List<Marker> buildNearbyUserMarkers(Set<DocumentSnapshot> docs) {
    //Make marker for result from Firestore query
    List<Marker> userMarkers = new List<Marker>();
    for (DocumentSnapshot doc in docs) {
      String geohash = doc.data['position']['geohash'];
      String id = doc.data['id'];
      Point geopoint = Geohash.decode(geohash);
      LatLng markerPosition = LatLng(geopoint.x, geopoint.y);
      
      userMarkers.add(
        Marker(
          markerId: MarkerId(id),
          icon: userPin,
          position: markerPosition,
          infoWindow: InfoWindow(title: 'User Submitted Backdrop'),
          onTap: () => showUserPhotoBox(id)
        )
      );
    }

    return userMarkers;
  }
  
  void showPhotoBox(String placeId) {
    if (placeId != _placeId) {
      setState(() {
        mapHeightWithBox = .5714;
        _placeId = placeId;
        _pressed = true;
        _userBox = false;
      });
    }
  }

  void showUserPhotoBox(String backdropID) {
    setState(() {
        mapHeightWithBox = .5714;
        _userBackdropId = backdropID;
        _pressed = false;
        _userBox = true;
      });
  }

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }
    
  Future <void> _handlePressSearch() async {
    try {
      Prediction p = await PlacesAutocomplete.show(       
          context: context,
          strictbounds: _center == null ? false : true,
          apiKey: global.kGoogleApiKey,
          onError: onError,
          mode: Mode.overlay,
          language: "en",
          location: _center == null
              ? null
              : Location(_center.latitude, _center.longitude),
          radius: _center == null ? null : 3940000);

      PlacesDetailsResponse place = await _places.getDetailsByPlaceId(p.placeId);
      LatLng placeLocation = LatLng(place.result.geometry.location.lat, place.result.geometry.location.lng);
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 15.0, target: placeLocation)));
      showPhotoBox(p.placeId);
      getUserBackdrops(placeLocation);
      getNearbyPlaces(placeLocation);
    } catch (e) {
      return;
    }
  }
}