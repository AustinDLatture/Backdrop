import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:backdrop/global.dart' as global;

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: global.kGoogleApiKey);

class PhotoBox extends StatefulWidget {
  String placeId;

  PhotoBox(String placeId) {
    this.placeId = placeId;
  }

  @override
  State<StatefulWidget> createState() {
    return PhotoBoxState();
  }
}

class PhotoBoxState extends State<PhotoBox> {
  //GoogleMapController mapController;
  PlacesDetailsResponse place;
  PlaceDetails placeDetails;
  Future<PlacesDetailsResponse> _place;
  double boxHeight = .2778;
  
  @override
  void initState() {
    super.initState();
    _place = fetchPlaceDetail();
  }

  @override
  void didUpdateWidget(PhotoBox oldPhotoBox) {
    if (oldPhotoBox.placeId != widget.placeId) {
      _place = fetchPlaceDetail();
    }
    super.didUpdateWidget(oldPhotoBox);
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: _place,
      builder: (BuildContext context, AsyncSnapshot<PlacesDetailsResponse> snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.none:
            return new Text('No photos');
          case ConnectionState.waiting:
            return new Container(
              height: (MediaQuery.of(context).size.height) * boxHeight,
              child: SpinKitWave(color: global.mainPurple, type: SpinKitWaveType.center)
            );
          case ConnectionState.active:
            return new Container(
              height:(MediaQuery.of(context).size.height) * boxHeight,
              child: SpinKitWave(color: global.mainPurple, type: SpinKitWaveType.center)
            );
          case ConnectionState.done:
            return new Container(
              color: global.mainPurple,
              height: (MediaQuery.of(context).size.height) * boxHeight,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: buildPhotoList(this.placeDetails),
                  )
                ],
              )
            ); 
        }
        return null;
      }
    );
  }

  Future<PlacesDetailsResponse> fetchPlaceDetail() async {
    PlacesDetailsResponse place =
        await _places.getDetailsByPlaceId(widget.placeId);
        if (place.status == 'OK') {
          setState((){
            this.place = place;
            this.placeDetails = place.result;
          });
        }
    return place;
  }

  String buildPhotoURL(String photoReference) {
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=${global.kGoogleApiKey}";
  }

  ListView buildPhotoList(PlaceDetails placeDetail) {
    List<Widget> list = [];
    if (placeDetail.photos != null) {
      final photos = placeDetail.photos;
      list.add(SizedBox(
          height: (MediaQuery.of(context).size.height) * boxHeight,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.only(right: 1.0),
                    child: 
                      SizedBox(
                      height: (MediaQuery.of(context).size.height) * boxHeight,
                      child: Image.network(buildPhotoURL(photos[index].photoReference)),
                    )
                  );
                })
              )
            ); 
    } else {
      list.add(SizedBox(
          height: (MediaQuery.of(context).size.height) * boxHeight,
          child: Container(color: global.mainPurple, child: 
            Align(
              alignment: Alignment.center,
              child: Text("No photos available :(",
              style: TextStyle(color: Colors.white, fontFamily: "Freight Sans", fontSize: 50, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
              )
            )
          )
        )
      );
    }
    return ListView(
      shrinkWrap: true,
      children: list,
    );
  }
}