


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:oers/ui/auth/login_screen.dart';
import 'package:oers/ui/firestore/firestore_list_screen.dart';

class SplashServices{

  void islogin(BuildContext context){

    final auth = FirebaseAuth.instance;

    final user = auth.currentUser;

    if(user!=null) {
      Timer(const Duration(seconds: 3),
              () =>
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) =>FireStoreScreen())));
    }
    else{
      Timer(const Duration(seconds: 3),
              () =>
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => loginScreen())));

    }


  }
}