import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oers/ui/posts/Tiesheet.dart';


class Tournament extends StatefulWidget {
  const Tournament({Key? key}) : super(key: key);

  @override
  State<Tournament> createState() => _TournamentState();
}

class _TournamentState extends State<Tournament> {


  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Join"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [


          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                // Check the number of participants already in the collection
                int count = (await FirebaseFirestore.instance
                    .collection('RandomParticipants')
                    .get())
                    .size;



                // If the number of participants is less than 20, allow the user to join
                if (count < 20) {
                  // Retrieve data from source collection with only 2 specific fields
                  QuerySnapshot sourceSnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .where('userId', isEqualTo: auth.currentUser!.uid)
                      .get();

                  List<Map<String, dynamic>> dataList = [];

                  sourceSnapshot.docs.forEach((doc) {
                    Map<String, dynamic> data = {
                      'Username': doc['Username'] as String,
                      'Rank': doc['Rank'] as double?,
                      'Game id': doc['Game id'] as String?,
                      'userId': doc['userId'] as String?,
                    };
                    dataList.add(data);
                  });

                  // Set data to destination collection
                  await FirebaseFirestore.instance
                      .collection('RandomParticipants')
                      .doc(auth.currentUser!.uid)
                      .set(dataList.fold({}, (prev, element) => {...prev, ...element}));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Joined"),
                      duration: Duration(seconds: 5),
                    ),
                  );


                } else {
                  // If the number of participants is already 20 or more, display an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("The maximum number of participants has been reached."),
                      duration: Duration(seconds: 5),
                    ),
                  );

                }
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => TieSheet()));
              },
              child: Text("Join with Randoms"),
            ),


          ),

        ],
      ),
    );
  }
}
