import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Uploader extends StatefulWidget {

  final File file;

  Uploader({Key key, this.file}) : super(key: key);
  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://backdrop-1563148655138.appspot.com');

  StorageUploadTask _uploadTask;

  void _startUpload() {
    String filePath = 'backdrops/${DateTime.now()}.png'; //figure out more intelligent naming

    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.file);
    });
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