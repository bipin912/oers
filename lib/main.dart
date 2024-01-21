import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:oers/ui/splash_screen.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Set the maximum download buffer size to 5MB
  FirebaseStorage storage = FirebaseStorage.instance;
  storage.setMaxUploadRetryTime(Duration(seconds: 5));










  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green
      ),debugShowCheckedModeBanner: false,


      home: SplashScreen(),

    );
  }
}


