import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';


import 'package:firebase_auth/firebase_auth.dart';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:oers/widgets/OrderTypeButton.dart';
import 'package:oers/widgets/round_button.dart';

import '../../backend/facedetection.dart';
import '../../utils/utils.dart';
import '../../widgets/button_controller.dart';


class AddFirestoreDataScreen extends StatefulWidget {
  const AddFirestoreDataScreen({Key? key}) : super(key: key);

  @override
  State<AddFirestoreDataScreen> createState() => _AddFirestoreDataScreenState();
}


class _AddFirestoreDataScreenState extends State<AddFirestoreDataScreen> {
  final usernameController = TextEditingController();
  final agecontroller = TextEditingController();
  final gamecontroller = TextEditingController();

  final gameidcontroller= TextEditingController();

  final levelcontroller = TextEditingController();


  bool loading = false;

  final fireStore = FirebaseFirestore.instance.collection('users');

  //final databaseRef = FirebaseDatabase.instance.ref('bio');
  final FirebaseAuth auth = FirebaseAuth.instance;





  @override
  Widget build(BuildContext context) {
    Get.put(ButtonController());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Add Bio'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [

            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                  hintText: 'Username', border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: agecontroller,
              decoration: InputDecoration(
                  hintText: 'Age', border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: gamecontroller,
              decoration: InputDecoration(
                  hintText: 'Game', border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 2,
            ),
            ElevatedButton(onPressed: ()=>showDialog(
                builder: (BuildContext context)=>
            AlertDialog(
              title: Text('Ranks'),
              content: Column(
                children: [
                  OrderTypeButton(value: 1, title: "Iron"),
                  OrderTypeButton(value: 2, title: "Bronze"),
                  OrderTypeButton(value: 3, title: "Silver"),
                  OrderTypeButton(value: 4, title: "Gold"),
                  OrderTypeButton(value: 5, title: "Platinum"),
                  OrderTypeButton(value: 6, title: "Diamond"),
                  OrderTypeButton(value: 7, title: "Ascendant"),
                  OrderTypeButton(value: 8, title: "Immortal"),
                  OrderTypeButton(value: 9, title: "Radiant"),
                ],
              ),
              actions: [
                TextButton(onPressed:(){
                  Navigator.pop(context);
                }, child: Text('ok'))
              ],

            ), context: context,
            )
              , child: Text('Choose your Rank')),
            SizedBox(
              height: 2,
            ),
            RoundButton(title: 'Upload image', onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => FaceDetectionScreen()));
            },),

            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: levelcontroller,
              decoration: InputDecoration(
                  hintText: 'level', border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: gameidcontroller,
              decoration: InputDecoration(
                  hintText: 'GameID', border: OutlineInputBorder()),
            ),

            SizedBox(
              height: 5,
            ),
            RoundButton(
                title: 'Update',
                loading: loading,
                onTap: () {
                  if (usernameController.text.isEmpty ||
                      agecontroller.text.isEmpty ||
                      gamecontroller.text.isEmpty ||
                      levelcontroller.text.isEmpty ||
                      gameidcontroller.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please fill up all the form"),
                        duration: Duration(seconds: 5),
                      ),
                    );
                    return;
                  }



                  Navigator.pop(context);
                  setState(() {
                    loading = true;
                  });
                  String id = auth.currentUser!.uid;

                  fireStore.doc(id).update({
                    'Username': usernameController.text.toString(),
                    'Age': agecontroller.text.toString(),
                    'Game': gamecontroller.text.toString(),
                    'level': levelcontroller.text.toString(),
                    'Game id':gameidcontroller.text.toString(),

                    'userId': id,
                  }).then((value) {
                    Utils().toastMessage('Bio Updated');
                    setState(() {
                      loading = false;
                    });
                  }).onError((error, stackTrace) {
                    setState(() {
                      loading = false;
                    });
                    Utils().toastMessage(error.toString());
                  });

                  //DateTime.now().millisecondsSinceEpoch.toString();
                })
          ],
        ),
      ),
    );

  }
}





