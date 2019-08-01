import 'dart:async';
import 'dart:collection';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import '../ui/photo_box.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';
 
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
  int radius = 1000;
  Map markerMap = new HashMap<String, String>();
 
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    Widget expandedChild;
    if (isLoading) {
      expandedChild = Center(child: SpinKitWave(color: Colors.green[300], type: SpinKitWaveType.center));
    } else if (errorMessage != null) {
      expandedChild = Center(
        child: Text(errorMessage),
      );
    } else {
      expandedChild = buildPlacesList();
    }
 
    return Scaffold(
      key: homeScaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Nearby Backdrops",
          style: TextStyle(color: Colors.green)
          ),
        actions: <Widget>[
          IconButton(
            color: Colors.green[300],
            icon: Icon(Icons.search),
            onPressed: () {
              _handlePressSearch();
            },
          ),
          IconButton(
            color: Colors.green[300],
            icon: Icon(Icons.pageview),
            iconSize: 40.0,
            onPressed: () {
              //Open advanced search
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(            
            child: SizedBox(            
                height: 290.0,
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
          Expanded(child: expandedChild)
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
        //TODO: Check for the resolution to this bug in Google Maps iOS SDK
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
                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        zoom: 15.0, 
                        target: new LatLng(f.geometry.location.lat, f.geometry.location.lng))));                                               
                },
                highlightColor: Colors.lightGreenAccent,
                splashColor: Colors.green[300],
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
        final result = await _places.searchNearbyWithRadius(location, radius);
        setState(() {
          this.isLoading = false;
          if (result.status == "OK") {
            this.places = result.results;
            result.results.forEach((f) {          
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
              apiKey: kGoogleApiKey,
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
  }