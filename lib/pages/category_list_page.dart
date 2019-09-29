
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:flutter/services.dart';
import 'package:backdrop/global.dart' as global;
import 'package:google_maps_webservice/places.dart';
import '../ui/photo_box.dart';
import 'dart:async';

/*
Here's how this will work:

Build JSON structure of 'place types' to actual placeTypes
When user presses button on categories page, parse the JSON for their selection

Ex: If they choose nature, do async call for all nearby places then map over them looking
for the actual placeTypes that correspond with nature

places List below should be data representation of the result of this async call

Then just pass those places to the list builder function and bam, good to go.

*/

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: global.kGoogleApiKey);
class CategoryListPage extends StatefulWidget {
  String category;

  @override
  State<StatefulWidget> createState() {
    return CategoryListPageState();
  }

  CategoryListPage(categories) {
    this.category = categories;
  }

}

class CategoryListPageState extends State<CategoryListPage> {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  List<PlacesSearchResult> places = [];
  double smallRadius = 10;
  LatLng center;
  var location;
  String category;
  bool isLoading = false;
  String errorMessage;

  var placeMap = {
    'travel': ['airport',  'bus_station', 
            'campground', 'subway_station”', 
            'train_station', 'taxi_stand',  
            'transit_station'],
    'fun': ['amusement_park', 'bowling alley', 
          'casino', 'aquarium', 'movie_theater', 
          'night_club', 'spa',  'stadium', 'zoo'],
    'art': ['art_gallery', 'museum',  'painter'],
    'food': ['bakery', 'bar', 'cafe', 'restaurant',  'supermarket'],
    'shopping': ['bicycle_store', 'book_store', 'jewelry_store', 
          'pet_store',	'clothing_store', 'convenience_store', 
          'department_store', 'shoe_store', 'electronics_store',
          'store', 'furniture_store','hardware_store', 'home_goods_store',
          'shopping_mall'],
    'architecture': ['city_hall',  'courthouse',  'embassy', 'lodging'],
    'nature': ['park',  'florist']
    };

  @override
  Widget build(BuildContext context) {
    getCategoryAndCenter();
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    Widget expandedChild;
    if (isLoading) {
      expandedChild = Center(child: SpinKitWave(color: global.seafoamGreen, type: SpinKitWaveType.center));
    } else if (errorMessage != null) {
      expandedChild = Center(
        child: Text(errorMessage),
      );
    } else {
      expandedChild = buildPlacesListWithPhotoBoxes('nature');
    }
    
    return Scaffold(
      key: homeScaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: global.seafoamGreen,
        title: const Text(
          "Nature",
          style: TextStyle(color: Colors.white, fontFamily: "Freight Sans", fontStyle: FontStyle.italic)
        )
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: expandedChild)
        ]
      )
    );
  }

  void getNearbyPlacesForCategory(String category, LatLng center) async {
    setState(() {
      this.isLoading = true;
      this.errorMessage = null;
    });

    var mapsCategories = placeMap[category];
    var returnedPlaces = [];
    final location = Location(center.latitude, center.longitude);
    final result = await _places.searchNearbyWithRadius(location, 10);
    
    setState(() {
      this.isLoading = false;
      if (result.status == "OK") {
          //loop/filter goes here
          this.places = result.results;
      } else {
          this.errorMessage = result.errorMessage;
      }
    });
  }

  void getCategoryAndCenter() async {
    this.center = await getUserLocation();
    //Figure out how to pass data between screens and replace 'nature' with 
    //that data wherever you find it
    getNearbyPlacesForCategory('nature', center);
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

  ListView buildPlacesListWithPhotoBoxes(String category) {
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
              //push to map screen                          
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
    return ListView(shrinkWrap: true, children: placesWidget);
  }
}