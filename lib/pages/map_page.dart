import 'dart:async';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import '../ui/photo_box.dart';
 
const kGoogleApiKey = "AIzaSyBSN2njU9C-NnWUUlDzSiljSy6AViPCEMk";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
String placeId;
 
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
  String _placeId;
 
  @override
  Widget build(BuildContext context) {
    Widget expandedChild;
    if (isLoading) {
      expandedChild = Center(child: CircularProgressIndicator(value: null));
    } else if (errorMessage != null) {
      expandedChild = Center(
        child: Text(errorMessage),
      );
    } else {
      expandedChild = buildPlacesList();
    }
 
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Nearby Backdrops",
          style: TextStyle(color: Colors.grey)
          ),
        actions: <Widget>[
          isLoading
              ? IconButton(
                  color: Colors.grey,
                  icon: Icon(Icons.timer),
                  onPressed: () {},
                )
              : IconButton(
                  color: Colors.grey,
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    refresh();
                  },
                ),
          IconButton(
            color: Colors.grey,
            icon: Icon(Icons.search),
            onPressed: () {
              _handlePressButton();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(            
            child: SizedBox(            
                height: 260.0,
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
          Container( //Padding at bottom             
            height: 30.0,                          
          ) 
        ],
      )
    );
  }
 
  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
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
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: center == null ? LatLng(0, 0) : center, zoom: 15.0)));
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
 
  ListView buildPlacesList() {
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
          ),
        ));
      }
      if (f.vicinity != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.vicinity,
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
            },
            highlightColor: Colors.lightBlueAccent,
            splashColor: Colors.blueAccent,
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
 
    return ListView(shrinkWrap: true, children: placesWidget);
  }
  
    void getNearbyPlaces(LatLng center) async {
    setState(() {
      this.isLoading = true;
      this.errorMessage = null;
    });
 
    final location = Location(center.latitude, center.longitude);
    final result = await _places.searchNearbyWithRadius(location, 2500);
    setState(() {
      this.isLoading = false;
      if (result.status == "OK") {
        this.places = result.results;
        result.results.forEach((f) {
          final markerOptions = MarkerOptions(
              position:
                  LatLng(f.geometry.location.lat, f.geometry.location.lng),
              infoWindowText: InfoWindowText("${f.name}", "${f.types?.first}"));
          mapController.addMarker(markerOptions);
        });
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

  Future <void> _handlePressButton() async {
    try {
      final center = await getUserLocation();
      Prediction p = await PlacesAutocomplete.show(       
          context: context,
          strictbounds: center == null ? false : true,
          apiKey: kGoogleApiKey,
          onError: onError,
          mode: Mode.fullscreen,
          language: "en",
          location: center == null
              ? null
              : Location(center.latitude, center.longitude),
          radius: center == null ? null : 10000);
          print("handlePressButton");
          
      showPhotoBox(p.placeId);
    } catch (e) {
      return;
    }
  }
}