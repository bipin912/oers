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

  final bioController = TextEditingController();

  bool loading = false;

  final databaseRef = FirebaseDatabase.instance.ref('Bio');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              controller: bioController,
              decoration: InputDecoration(
                  hintText: 'Username', border: OutlineInputBorder()),
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
                databaseRef.child(DateTime.now().millisecondsSinceEpoch.toString()).set({
              'Username': bioController.text.toString(),
                  'id': DateTime.now().millisecondsSinceEpoch.toString()
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
  }
}
