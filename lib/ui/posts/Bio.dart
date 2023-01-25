import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:oers/widgets/round_button.dart';

import '../../utils/utils.dart';

class bio extends StatefulWidget {
  const bio({Key? key}) : super(key: key);

  @override
  State<bio> createState() => _bioState();
}

class _bioState extends State<bio> {

  final usernameController = TextEditingController();
  final agecontroller=TextEditingController();
  final gamecontroller=TextEditingController();
  final rankcontroller=TextEditingController();
  final levelcontroller=TextEditingController();


  bool loading = false;

  final databaseRef = FirebaseDatabase.instance.ref('bio');


  @override
  Widget build(BuildContext context) {
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
              height: 30,
            ),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                  hintText: 'Username', border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 30,
            ),
            TextFormField(
              controller: agecontroller,
              decoration: InputDecoration(
                  hintText: 'Age', border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 30,
            ),
            TextFormField(
              controller: gamecontroller,
              decoration: InputDecoration(
                  hintText: 'Game', border: OutlineInputBorder()),
            ),SizedBox(
              height: 30,
            ),
            TextFormField(
              controller: rankcontroller,
              decoration: InputDecoration(
                  hintText: 'Rank', border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 30,
            ),
            TextFormField(
              controller: levelcontroller,
              decoration: InputDecoration(
                  hintText: 'level', border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 30,
            ),
            RoundButton(
                title: 'Update',
                loading: loading,
                onTap: () {
                  setState(() {
                    loading=true;
                  });
                databaseRef.set({

              'Username': usernameController.text.toString(),
                  'Age': agecontroller.text.toString(),
                  'Game':gamecontroller.text.toString(),
                  'Rank':rankcontroller.text.toString(),
                  'level':levelcontroller.text.toString(),
                  'id': DateTime.now().millisecondsSinceEpoch.toInt()
            }).then((value){
                  Utils().toastMessage('Bio Updated');
                  setState(() {
                    loading=false;
                  });

                }).onError((error, stackTrace){
                  Utils().toastMessage(error.toString());
                  setState(() {
                    loading=false;
                  });
                });
            })
          ],
        ),
      ),
    );
    // Future<void> showUserNameDialogAlert(BuildContext){
    //   return showDialog(context: context,
    //       builder:(context){
    //     return AlertDialog();
    //
    //       });
    //
    // }
  }
}
