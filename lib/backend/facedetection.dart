import 'dart:io';
import 'package:flutter/widgets.dart' show Image;


import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Img;
import 'package:image_picker/image_picker.dart' ;

import 'package:oers/utils/utils.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/round_button.dart';








class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({Key? key}) : super(key: key);

  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {

  bool loading=false;
  late final FaceDetector _faceDetector;
  File? _image;

  List<Face> _faces = [];
  final picker = ImagePicker();

  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance.collection('users');

  Future<void> _initialize() async {
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableContours: true,
        enableClassification: true,
      ),
    );
  }

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        // _resizeImage(_image!);
      } else {
        Utils().toastMessage("No image selected");
      }
    });
  }


  // Future<void> _resizeImage(File imageFile) async {
  //   final imageSize = await imageFile.length();
  //   final sizeInKb = imageSize / 1024;
  //   final maxWidth = 1000; // The maximum width you want for your image
  //   final maxHeight = 1280; // The maximum height you want for your image
  //   if (sizeInKb > 1024) {
  //     // Resize the image if it's larger than 1 MB
  //     final decodedImage = Img.decodeImage(imageFile.readAsBytesSync())!;
  //     final resizedImage = Img.copyResize(decodedImage,
  //         width: decodedImage.width > maxWidth ? maxWidth : decodedImage.width,
  //         height:
  //         decodedImage.height > maxHeight ? maxHeight : decodedImage.height);
  //     final resizedFile = File(imageFile.path)
  //       ..writeAsBytesSync(Img.encodeJpg(resizedImage, quality: 85));
  //   }
  // }


  Future<List<Face>> processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);

    final faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
      ),
    );

    final faces = await faceDetector.processImage(inputImage);

    await faceDetector.close();

    setState(() {
      _faces = faces;
    });

    return faces;
  }

  Future<void> uploadImage() async {
    if (_faces.length == 1 && _faces[0].headEulerAngleY! < 20 && _faces[0].headEulerAngleY! > -20) {
      final user = auth.currentUser!;
      final storage = FirebaseStorage.instance;
      if (_image != null) {
        // Resize the image to reduce the size
        // _resizeImage(_image!);

        final path = "users/${user.uid}/face.jpg";
        final ref = storage.ref().child(path);
        await ref.putFile(_image!);
        final url = await ref.getDownloadURL();
        print("URL: $url");

        fireStore.doc(user.uid)
            .update({"faceUrl": url});
        print("Document updated successfully!");
        Utils().toastMessage("Face uploaded successfully!");
      } else {
        Utils().toastMessage("No image selected!");
      }
    } else {
      Utils().toastMessage("No face detected or multiple faces detected!");
    }
  }




  @override
  void initState() {
    super.initState();
    _initialize();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Face Detection"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 300,
              width: 300,
              child: _image == null
                  ? Center(child: Text("No Image Selected"))
                  : FittedBox(child: Image.file(_image!)),
            ),
          ),
          SizedBox(height: 20),
          RoundButton(
            loading : loading,
            onTap: () async {
              setState(() {
                loading= true;
              });

              await getImage(ImageSource.camera);
              await processImage(_image!);
              await uploadImage();
              setState(() {
                loading = false;
              });
            },
            title: 'Upload Face',
          ),
        ],
      ),
    );

  }
}