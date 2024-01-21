
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'package:flutter/material.dart';
import 'package:oers/backend/facedetection.dart';
import 'package:oers/ui/auth/login_screen.dart';
import 'package:oers/ui/firestore/add_firestore_data.dart';

import 'package:oers/utils/utils.dart';


import '../posts/Tournament.dart';
class FireStoreScreen extends StatefulWidget {
  const FireStoreScreen({Key? key}) : super(key: key);

  @override
  State<FireStoreScreen> createState() => _FireStoreScreenState();
}

class _FireStoreScreenState extends State<FireStoreScreen> {
   final auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Welcome to OERS'),
        actions: [
          IconButton(
              onPressed: () {
                auth.signOut().then((value) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => loginScreen()));
                }).onError((error, stackTrace) {
                  Utils().toastMessage(error.toString());
                });
              },
              icon: Icon(Icons.logout)),
          SizedBox(width: 10)
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height:10),
      StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Some error has occurred');
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text('Hello new friend! Welcome to OERS. Please use + button to add your Bio');
          }

          final data = snapshot.data!.data();

          return Expanded(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    if (data != null && data.containsKey('Username'))
                      ListTile(
                        onTap: () {},
                        title: Text(data['Username']),
                        subtitle: Text('Username'),
                      ),
                    if (data != null && data.containsKey('Age'))
                      ListTile(
                        title: Text(data['Age']),
                        subtitle: Text('Age'),
                      ),
                    if (data != null && data.containsKey('Game'))
                      ListTile(
                        title: Text(data['Game']),
                        subtitle: Text('Game'),
                      ),
                    if (data != null && data.containsKey('Rank'))
                      ListTile(
                        title: Text(data['Rank'].toString()),
                        subtitle: Text('Your rank according to OERS'),
                      ),
                    if (data != null && data.containsKey('level'))
                      ListTile(
                        title: Text(data['level']),
                        subtitle: Text('Level'),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),

          ElevatedButton(
            onPressed: () async {
              final doc = await FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).get();

              final data = doc?.data();
              if (doc == null ||
                  data == null ||
                  !data.containsKey('Username') ||
                  !data.containsKey('Game id') ||
                  !data.containsKey('Age') ||
                  !data.containsKey('faceUrl') ||
                  !data.containsKey('Rank') ||
                  !data.containsKey('level')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please update your Bio'),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Tournament()),
                );
              }
            },
            child: Text('Join Valorant Tournament'),
          ),



        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddFirestoreDataScreen()));
        },
        child: Icon(Icons.add),
      ),

    );


  }

}


