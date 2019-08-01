import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

const kGoogleApiKey = "AIzaSyBSN2njU9C-NnWUUlDzSiljSy6AViPCEMk";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

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
  GoogleMapController mapController;
  PlacesDetailsResponse place;
  PlaceDetails placeDetails;
  Future<PlacesDetailsResponse> _place;
  
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
              height: 190.0,
              width: MediaQuery.of(context).size.width,
              child: SpinKitWave(color: Colors.green[300], type: SpinKitWaveType.center)
            );
          case ConnectionState.active:
            return new Container(
              height: 190.0,
              width: MediaQuery.of(context).size.width,
              child: SpinKitWave(color: Colors.blueAccent, type: SpinKitWaveType.center)
            );
          case ConnectionState.done:
            return new Container(
              height: 190.0,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: buildPhotoList(this.placeDetails),
                    )
                  ],
                )
              ); 
        }
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
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${photoReference}&key=${kGoogleApiKey}";
  }

  ListView buildPhotoList(PlaceDetails placeDetail) {
    List<Widget> list = [];
    if (placeDetail.photos != null) {
      final photos = placeDetail.photos;
      list.add(SizedBox(
          height: 185.0,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.only(right: 1.0),
                    child: SizedBox(
                      height: 100,
                      child: Image.network(
                          buildPhotoURL(photos[index].photoReference)
                        ),
                    )
                  );
              })
            )
          );
    }
    return ListView(
      shrinkWrap: true,
      children: list,
    );
  }
}