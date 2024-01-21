import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;
import 'package:flutter/widgets.dart' show Image;

import '../utils/utils.dart';
import '../widgets/round_button.dart';

class FaceRecognitionPage extends StatefulWidget {
  @override
  _FaceRecognitionPageState createState() => _FaceRecognitionPageState();
}


class _FaceRecognitionPageState extends State<FaceRecognitionPage> {

  bool loading = false;


  // Load the TensorFlow Lite model
  late Interpreter interpreter;
  Face? _faces;

  File? cameraImage;

  // Firebase image bytes
  Uint8List? firebaseImageBytes;


  // Camera image bytes
  Uint8List? cameraImageBytes;

  // Whether the user is eligible to play

  bool isEligible = false;

  // Current user
  late User user;

  @override
  void initState() {
    super.initState();

    // Load the model
    Interpreter.fromAsset('mobilefacenet.tflite').then((interpreter) {
      this.interpreter = interpreter;
    });

    // Load the current user
    user = FirebaseAuth.instance.currentUser!;
  }


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
      _faces = faces.isNotEmpty ? faces.first : null;
    });

    return faces;
  }

  imglib.Image _cropFace(Uint8List image, Face faceDetected) {
    imglib.Image? convertedImage = imglib.decodeImage(image);
    var img1 =imglib.copyRotate(convertedImage!, -90);

    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;

    return imglib.copyCrop(
        img1, x.round(), y.round(), w.round(), h.round());
  }

  Float32List imageToByteListFloat32(imglib.Image image) {


    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image!.getPixel(j, i);
        var red = imglib.getRed(pixel);
        var green = imglib.getGreen(pixel);
        var blue = imglib.getBlue(pixel);
        buffer[pixelIndex++] = (red - 128) / 128;
        buffer[pixelIndex++] = (green - 128) / 128;
        buffer[pixelIndex++] = (blue - 128) / 128;
      }
    }

    return convertedBytes.buffer.asFloat32List();
  }

  double cosineSimilarity(List<double> a, List<double> b) {
    double dotProduct = 0;
    double magnitudeA = 0;
    double magnitudeB = 0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      magnitudeA += pow(a[i], 2);
      magnitudeB += pow(b[i], 2);
    }

    magnitudeA = sqrt(magnitudeA);
    magnitudeB = sqrt(magnitudeB);
    double similarity = dotProduct / (magnitudeA * magnitudeB);
    print(similarity);
    return similarity;
  }

  Future<double> compareFaces() async {


    // Capture an image from the camera
    PickedFile? pickedFile =
    await ImagePicker().getImage(source: ImageSource.camera);
    cameraImageBytes =
        File(pickedFile!.path).readAsBytesSync(); // update the class field
    setState(
          () {
        if (pickedFile != null) {
          cameraImage = File(pickedFile.path);
          // _resizeImage(_image!);
        } else {
          Utils().toastMessage("No image selected");
        }
      },
    );

    final tempDir = await getTemporaryDirectory();

    final tempFile2 = File('${tempDir.path}/temp_file2.jpg');
    await tempFile2.writeAsBytes(cameraImageBytes!);


    //for Captured Image
    var fc1 = await processImage(tempFile2);


    //crop the face
    imglib.Image cameracroppedImage = _cropFace(cameraImageBytes!, fc1.first!);
    imglib.Image cmimg = imglib.copyResizeCropSquare(cameracroppedImage, 112);
    Float32List cmimageAsList = imageToByteListFloat32(cmimg);

    //Changing to required model
    List cameraInputs = cmimageAsList;
    cameraInputs = cameraInputs.reshape([1, 112, 112, 3]);
    List cameraOutputs = List.generate(1, (index) => List.filled(192, 0));



    // Run the model on the captured image
    interpreter.run(cameraInputs, cameraOutputs);
    cameraOutputs = cameraOutputs.reshape([192]);
    print('b');
    print(cameraOutputs[0]);


    //conversion in List<double> format from List<dynamic>

    List<double> list2 =
    cameraOutputs.map<double>((output) => output.toDouble()).toList();



    // Get the Firebase Cloud Storage image
    final path = "users/${user.uid}/face.jpg";
    final ref = FirebaseStorage.instance.ref().child(path);
    firebaseImageBytes = await ref.getData();

    print('a');




    final tempFile1 = File('${tempDir.path}/temp_file1.jpg');
    await tempFile1.writeAsBytes(firebaseImageBytes!);

    print('b');



    //for firebase Image

    var fc = await processImage(tempFile1);
    print('c');

    //crop the face
    imglib.Image croppedImage = _cropFace(firebaseImageBytes!, fc.first);
    imglib.Image fbimg = imglib.copyResizeCropSquare(croppedImage, 112);

    Float32List fbimageAsList = imageToByteListFloat32(fbimg);
    print('d');

    //Changing to required model format
    List firebaseInputs = fbimageAsList;
    firebaseInputs = firebaseInputs.reshape([1, 112, 112, 3]);
    List firebaseOutputs = List.generate(1, (index) => List.filled(192, 0));
    print('eight');


    // Run the model on the Firebase Cloud Storage image
    interpreter.run(firebaseInputs, firebaseOutputs);
    firebaseOutputs = firebaseOutputs.reshape([192]);
    print('A');

    List<double> list1 =
    firebaseOutputs.map<double>((output) => output.toDouble()).toList();








    double similarity = cosineSimilarity(list1, list2);
    print(similarity);
    return similarity;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Recognition'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 300,
              width: 300,
              child: cameraImageBytes == null
                  ? Center(child: Text("No image selected"))
                  : FittedBox(child: Image.file(cameraImage!)),
            ),
          ),
          RoundButton(
            loading : loading, title: 'Check Eligiblity',

            onTap: () async {
              // Get current user ID
              User user = FirebaseAuth.instance.currentUser!;
              String uid = user.uid;

              // Check if user is a participant
              DocumentSnapshot userDoc = await FirebaseFirestore.instance
                  .collection('RandomParticipants')
                  .doc(uid)
                  .get();
              if (!userDoc.exists) {
                // Show snackbar saying not a participant
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("You are not a participant"),
                    duration: Duration(seconds: 5),
                  ),
                );
              } else {
                try {

                  setState(() {
                    loading = true;
                  });
                  // Compare faces
                  double similarity = await compareFaces();


                  // Check if eligible
                  bool isEligible = similarity > 0.71;

                  // Show snackbar based on eligibility
                  if (isEligible) {
                    String gameId = userDoc.get('Game id');

                    // Add user to eligible collection
                    FirebaseFirestore.instance
                        .collection('eligible')
                        .doc(uid)
                        .set({
                      'Game id': gameId,
                    });
                    print('eligible');
                    setState(() {
                      loading = false;
                    });

                    // Show snackbar saying eligible to play
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Eligible to play with similarity value: ${similarity
                                .toStringAsFixed(3)}"),
                        duration: Duration(seconds: 10),
                      ),
                    );
                  } else {
                    setState(() {
                      loading = false;
                    });
                    print('not eligible');

                    // Show snackbar saying not eligible
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Not Eligible to play with similarity value: ${similarity
                                .toStringAsFixed(3)}"),
                        duration: Duration(seconds: 10),
                      ),
                    );
                  }
                }
                catch (e,stackTrace) {
                  setState(() {
                    loading= false;
                  });
                  print('Error during face detection: $e');
                  print('Stack trace: $stackTrace');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Face not detected. Please upload again."),
                      duration: Duration(seconds: 5),

                    ),

                  );

                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    interpreter.close();
  }
}