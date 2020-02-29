import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:backdrop/global.dart' as global;

class UserPhotoBox extends StatefulWidget {
  String backdropID;

  UserPhotoBox(String backdropID) {
    this.backdropID = backdropID;
  }

  @override
  State<StatefulWidget> createState() {
    return UserPhotoBoxState();
  }
}

class UserPhotoBoxState extends State<UserPhotoBox> {
  String backdropID;
  StorageReference photosReference = FirebaseStorage.instance.ref().child('backdrops');
  Uint8List file;
  bool loading = true;
  
  @override
  void initState() {
    backdropID = widget.backdropID;
    getImage(backdropID);
    super.initState();
  }

  @override
  void didUpdateWidget(UserPhotoBox oldPhotoBox) {
    if (oldPhotoBox.backdropID != widget.backdropID) {
      this.backdropID = widget.backdropID;
    }
    super.didUpdateWidget(oldPhotoBox);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: global.mainPurple,
      height: (MediaQuery.of(context).size.height)/3.6,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Expanded(
            child: !loading ? buildPhotoList(this.backdropID) //If done loading, show the box
            : Container(
              height:(MediaQuery.of(context).size.height)/3.6,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: SpinKitWave(color: global.mainPurple, type: SpinKitWaveType.center)
            ),
          )
        ],
      )
    ); 
  }

  getImage(String backdropURL) {
    photosReference.child('$backdropURL.png').getData(10000000).then((data) {
      this.setState((){
        file = data;
        loading = false;
      });
    }).catchError((error){});
  }

  ListView buildPhotoList(String backdropID) {
    List<Widget> list = [];
    if (backdropID != null) {
      list.add(SizedBox(
          height: (MediaQuery.of(context).size.height)/3.6,
          child: Padding(
                padding: EdgeInsets.only(right: 1.0),
                child: SizedBox(
                  height: (MediaQuery.of(context).size.height)/3.6,
                  child: Image.memory(file)
                )
              )   
            )
          ); 
    } else {
      list.add(SizedBox(
          height: (MediaQuery.of(context).size.height)/3.6,
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

  