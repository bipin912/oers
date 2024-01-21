// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:get/get.dart';

class ButtonController extends GetxController{
  final fireStore = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth auth = FirebaseAuth.instance;


  double _orderType =0;
   get orderType => _orderType;

  void setOrderType(double type){
    _orderType= type;

    fireStore.doc(auth.currentUser!.uid).set({
      'Rank': _orderType.toDouble()}
    );

    print(_orderType);



    update();
  }

}
