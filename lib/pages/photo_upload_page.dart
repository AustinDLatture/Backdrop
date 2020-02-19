import 'dart:async';
import 'dart:io';
import 'package:backdrop/global.dart' as global;
import 'package:backdrop/ui/uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PhotoUploadPage extends StatefulWidget {
  final LatLng location;

  //Constructor for building page from map page
  PhotoUploadPage({this.location});

  @override
  State<StatefulWidget> createState() {
    return PhotoUploadPageState();
  }
}

class PhotoUploadPageState extends State<PhotoUploadPage> {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  LatLng _location;

  //Current image file
  File _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
        _imageFile = selected;
    });
  }

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
      toolbarColor: global.seafoamGreen,
      toolbarWidgetColor: Colors.white,
      toolbarTitle: 'Crop Image'
    );

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  void _clear() {
    setState(() => _imageFile = null);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

    if (widget.location != null) {
      this._location = widget.location;
    }

    return Scaffold(
      key: homeScaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: global.seafoamGreen,
        title: const Text(
          "Upload New Backdrop",
          style: TextStyle(color: Colors.white, fontFamily: "Freight Sans", fontStyle: FontStyle.italic)
        )
      ),
      body: Column(children: <Widget>[
          Container(
            height:(MediaQuery.of(context).size.height)/1.75,
            color: Colors.grey[350],
            child: _imageFile != null 
            ? Image.file(_imageFile, height: (MediaQuery.of(context).size.height)/1.75)
            : Container(height: (MediaQuery.of(context).size.height)/1.75,
                        width: MediaQuery.of(context).size.width,
                        child: Icon(Icons.add_photo_alternate, size: 150, color: Colors.grey)
                      )
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: global.seafoamGreen,
              child: Align(    
                alignment: Alignment.topCenter,
                child: Column(
                  children: <Widget>[
                        ButtonBar(
                          alignment: MainAxisAlignment.center,
                          buttonPadding: EdgeInsets.all(40),
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.camera, size: 48),
                              color: Colors.white, 
                              onPressed:() => _pickImage(ImageSource.camera)
                            ),
                            IconButton(
                              icon: Icon(Icons.photo_library, size: 48),
                              color: Colors.white, 
                              onPressed:() => _pickImage(ImageSource.gallery)
                            ),
                            IconButton(
                              icon: Icon(Icons.crop, size: 48),
                              color: Colors.white, 
                              onPressed: _cropImage
                            ),
                            IconButton(
                              icon: Icon(Icons.clear, size: 48),
                              color: Colors.white, 
                              onPressed: _clear
                            ),
                          ],
                        ),
                    Uploader(file: _imageFile, location: _location)
                  ],
                )
              )
            ) 
          )
        ],
      )
    );
  }

}