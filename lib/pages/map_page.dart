import 'dart:async';
import 'dart:math';
import 'package:backdrop/global.dart' as global;
import 'package:backdrop/pages/categories_page.dart';
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

String placeId;
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: global.kGoogleApiKey);
 
class MapPage extends StatefulWidget {
  final String filterCategory;
  
  MapPage({this.filterCategory});

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
  String filterCategory;
  LatLng _center = LatLng(0,0);
  Set<DocumentSnapshot> userBackdrops = new Set();

  Geoflutterfire geo = Geoflutterfire();
  var uuid = Uuid();

  //for testing
  LatLng gR = new LatLng(42.9634, -85.6681); 
 
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    Widget expandedChild;
    if (widget.filterCategory != null) {
      this.filterCategory = widget.filterCategory;
    }

    if (isLoading) {
      expandedChild = Center(child: SpinKitWave(color: global.seafoamGreen, type: SpinKitWaveType.center));
    } else if (errorMessage != null) {
      expandedChild = Center(
        child: Text(errorMessage),
      );
    } else {
      expandedChild = _pressed 
      ? new Container(color: global.seafoamGreen, child: 
        Center(child: 
          Text(
            ""
          )
        )
      )
      : new Container(color: global.seafoamGreen, child: 
        Center(child: 
          Text(
            "Welcome to Backdrop",
            style: TextStyle(fontFamily: "Freight Sans", fontStyle: FontStyle.italic, fontSize: 66, color: Colors.white),
            textAlign: TextAlign.center
          )
        )
      );
    }
 
    return Scaffold(
      key: homeScaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: global.seafoamGreen,
        title: const Text(
          "Nearby Backdrops",
          style: TextStyle(color: Colors.white, fontFamily: "Freight Sans", fontStyle: FontStyle.italic)
          ),
        actions: <Widget>[
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.search),
            onPressed: () {
              _handlePressSearch();
            },
          ),
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.add_a_photo),
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PhotoUploadPage(
                          location: this._center,
                      )
                )
              );
            },
          ),
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.photo_size_select_actual),
            iconSize: 40.0,
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoriesPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(            
            child: SizedBox(            
                height: (MediaQuery.of(context).size.height)/1.75, //Takes up .5714 of display
                child: GoogleMap(               
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(target: _center),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: markers               
                    )
                  ),
                ),
          _pressed 
          ? new Builder(builder: (BuildContext context) { return new PhotoBox(_placeId); }) 
          : _userBox ? new Builder(builder: (BuildContext context) { return new UserPhotoBox(_userBackdropId); })
            : new SizedBox(),
          Expanded(child: expandedChild),
          Container(padding: EdgeInsets.all(10.0), color: global.seafoamGreen)
        ],
      )
    );
  }
 
  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
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
    mapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 15.0, target: _center)));
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _center)));
    getNearbyPlaces(_center);
  }
     
  void showPhotoBox(String placeId) {
    if (placeId != _placeId) {
      setState(() {
        _placeId = placeId;
        _pressed = true;
        _userBox = false;
      });
    }
  }

  List<PlacesSearchResult> filterByCategory(List<PlacesSearchResult> places, String category) {
    //Can this be optimized?
    var placeMap = {
    'travel': ['airport',  'bus_station', 
            'campground', 'subway_station”', 
            'train_station', 'taxi_stand',  
            'transit_station'],
    'fun': ['amusement_park', 'bowling alley', 
          'casino', 'movie_theater', 
          'night_club', 'spa', 'stadium'],
    'art': ['art_gallery', 'museum',  'painter'],
    'food': ['bakery', 'bar', 'cafe', 'restaurant', 'supermarket'],
    'shopping': ['bicycle_store', 'book_store', 'jewelry_store', 
          'pet_store',	'clothing_store', 'convenience_store', 
          'department_store', 'shoe_store', 'electronics_store',
          'store', 'furniture_store','hardware_store', 'home_goods_store',
          'shopping_mall'],
    'architecture': ['city_hall', 'courthouse',  'embassy', 'lodging', 'political'],
    'nature': ['park',  'florist', 'aquarium', 'zoo']
    };
    List<PlacesSearchResult> filteredPlaces = [];
    List<String> placesCategories = placeMap[category];
    for (PlacesSearchResult place in places) {
      for (String category in placesCategories) {
        if (place.types.contains(category)) {
          filteredPlaces.add(place);
        }
      }
    }
    return filteredPlaces;
  }
      
  void getNearbyPlaces(LatLng center) async {
    setState(() {
      this.isLoading = true;
      this.errorMessage = null;
    });

    getUserBackdrops(center);
     
    final location = Location(center.latitude, center.longitude);
    final result = await _places.searchNearbyWithRadius(location, radius);
    
    setState(() {
      this.isLoading = false;
      if (result.status == "OK") {
        this.places = result.results;
        if(filterCategory != null) {
          this.places = filterByCategory(this.places, filterCategory);
        }
        this.places.forEach((f) {
          markers.add(
            Marker(
              markerId: MarkerId(f.placeId),
              position: LatLng(f.geometry.location.lat, f.geometry.location.lng),
              infoWindow: InfoWindow (title: f.name, snippet: "${f.types?.first}"),
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

  //Test this, ran out of time to restart into debug mode
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
          position: markerPosition,
          infoWindow: InfoWindow(title: 'User Submitted Backdrop'),
          onTap: () => showUserPhotoBox(id)
        )
      );
    }

    return userMarkers;
  }
  
  void showUserPhotoBox(String backdropID) {
    setState(() {
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
      getNearbyPlaces(placeLocation);
    } catch (e) {
      return;
    }
  }
}