import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class Uploader extends StatefulWidget {

  final File file;
  final LatLng location;

  Uploader({Key key, this.file, this.location}) : super(key: key);
  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://backdrop-1563148655138.appspot.com');
  Geoflutterfire geo = Geoflutterfire();
  var uuid = Uuid();
  StorageUploadTask _uploadTask;

  void _startUpload() {
    final String id = uuid.v1();
    String filePath = 'backdrops/$id.png'; 

    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.file);
    });

    //Upload to firestore
    _updateFirestore(id);
  }

  Future<void> _updateFirestore(String id) {
    GeoFirePoint _userLocation = 
    geo.point(latitude: widget.location.latitude, longitude: widget.location.longitude);
    return Firestore.instance.runTransaction((Transaction transactionHandler) =>
       Firestore.instance.collection('backdrops').document().setData({
        'id': '$id',
        'position': _userLocation.data
       })
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null && !_uploadTask.isComplete) {

      return StreamBuilder<StorageTaskEvent>(
        stream: _uploadTask.events,
        builder: (_, snapshot) {
          var event = snapshot?.data?.snapshot;

          double progressPercent = event != null
            ? event.bytesTransferred/event.totalByteCount : 0;

          return Column(children: <Widget>[
              if (_uploadTask.isComplete)
                Text('Upload complete'),

              if (_uploadTask.isPaused)
                FlatButton(child:  Icon(Icons.play_arrow),
                onPressed: _uploadTask.resume,
              ),

              if (_uploadTask.isInProgress)
                FlatButton(
                  child: Icon(Icons.pause),
                  onPressed: _uploadTask.pause,
                ),
              LinearProgressIndicator(value:progressPercent),
              Text(
                '${(progressPercent * 100).toStringAsFixed(2)} %'
              )
            ]
          );
        });
    } else {
      return IconButton(
        icon: Icon(Icons.cloud_upload, size: 48),
        color: Colors.white,
        onPressed: _startUpload
      );
    }
  }
}