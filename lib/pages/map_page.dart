import 'dart:async';
import 'dart:collection';
import 'package:backdrop/global.dart' as global;
import 'package:backdrop/pages/categories_page.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import '../ui/photo_box.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';

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
  String _placeId;
  int radius = 1000;
  Map markerMap = new HashMap<String, String>();
  String filterCategory;

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
      ? new Text("")
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
                height: (MediaQuery.of(context).size.height)/1.75, //Takes up 2/3 of display
                child: GoogleMap(                  
                    onMapCreated: _onMapCreated,
                    options: GoogleMapOptions(
                        myLocationEnabled: true,
                        cameraPosition:
                            const CameraPosition(target: LatLng(0.0, 0.0))))),
          ),
          _pressed 
          ? new Builder(builder: (BuildContext context) { return new PhotoBox(_placeId); }) 
          : new SizedBox(),
          Expanded(child: expandedChild),
          Container(padding: EdgeInsets.all(10.0), color: global.seafoamGreen)
        ],
      )
    );
  }
 
  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    mapController.onMarkerTapped.add(_onMarkerTapped);
    refresh();
  }
  
  Future <LatLng> getUserLocation() async {
    var currentLocation = <String, double>{};
    final location = LocationManager.Location();
    try {
      currentLocation = await location.getLocation();
      final lat = currentLocation["latitude"];
      final lng = currentLocation["longitude"];
      final center = LatLng(lat, lng);
      return center;
    } on Exception {
      currentLocation = null;
      return null;
    }
  }

  void refresh() async {
    final center = await getUserLocation();
    //Hacky workaround to center the camera. 
    mapController.moveCamera(CameraUpdate.newLatLng(center));
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 15.0, target: center)));
    getNearbyPlaces(center);
  }
     
  void showPhotoBox(String placeId) {
    if (placeId != _placeId) {
      setState(() {
        _placeId = placeId;
        _pressed = true;
      });
    }
  }

  List<PlacesSearchResult> filterByCategory(List<PlacesSearchResult> places, String category) {
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
          final markerOptions = MarkerOptions(
              position:
                LatLng(f.geometry.location.lat, f.geometry.location.lng),
                infoWindowText: InfoWindowText("${f.name}", "${f.types?.first}"),             
              );

          mapController.addMarker(markerOptions).then((marker) => 
            markerMap.putIfAbsent(marker.id, () => f.placeId)
          );
        }
      );
      } else {
        this.errorMessage = result.errorMessage;
      }
    });
  }
  
  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }
    
  Future <void> _handlePressSearch() async {
    try {
      final center = await getUserLocation();
      Prediction p = await PlacesAutocomplete.show(       
          context: context,
          strictbounds: center == null ? false : true,
          apiKey: global.kGoogleApiKey,
          onError: onError,
          mode: Mode.overlay,
          language: "en",
          location: center == null
              ? null
              : Location(center.latitude, center.longitude),
          radius: center == null ? null : 3940000);

      PlacesDetailsResponse place = await _places.getDetailsByPlaceId(p.placeId);
      LatLng placeLocation = LatLng(place.result.geometry.location.lat, place.result.geometry.location.lng);
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 15.0, target: placeLocation)));
          showPhotoBox(p.placeId);
    } catch (e) {
      return;
    }
  }
    
  void _onMarkerTapped(Marker marker) {
    return showPhotoBox(markerMap[marker.id]);
  }

  /*   UNCOMMENT IF MAKING LIST WIDGET
  Container buildPlacesList() {
    final placesWidget = places.map((f) {
      List<Widget> list = [
        Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Text(
            f.name,
            style: Theme.of(context).textTheme.subtitle,
          ),
        )
      ];
      if (f.formattedAddress != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.formattedAddress,
            style: TextStyle(fontFamily: "Freight Sans")
          ),
        ));
      }
      if (f.vicinity != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.vicinity,
            style: TextStyle(fontFamily: "Freight Sans")
          ),
        ));
      }
      return Padding(
        padding: EdgeInsets.only(top: 1.0, bottom: 1.0, left: 8.0, right: 8.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: InkWell(
            onTap: () {
                showPhotoBox(f.placeId);  
              mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    zoom: 15.0, 
                    target: new LatLng(f.geometry.location.lat, f.geometry.location.lng))));                                               
            },
            highlightColor: global.seafoamGreen,
            splashColor: global.seafoamGreen,
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: list,
              ),
            ),
          ),
        ),
      );
    }).toList();
    return Container(
      color: global.seafoamGreen,
      child: ListView(shrinkWrap: true, children: placesWidget)
    );
  }
  */
}