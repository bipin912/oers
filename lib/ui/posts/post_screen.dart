import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:oers/ui/auth/login_screen.dart';
import 'package:oers/ui/posts/Tournament.dart';
import 'package:oers/utils/utils.dart';
import 'package:oers/ui/posts/Bio.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseDatabase.instance.ref('Users');
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    ref.onValue.listen((event) { });
  }
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


              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Tournament() ));
              }, child: Text("Join Valorant Tournament"),)


          // Expanded(
          //     child: StreamBuilder(
          //         stream: ref.onValue,
          //         builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          //           if (!snapshot.hasData) {
          //             return CircularProgressIndicator();
          //           } else {
          //             Map<dynamic,dynamic> map = (snapshot.data?.snapshot.value??{}) as dynamic;
          //             List<dynamic> list=[];
          //             list.clear();
          //             list= map.values.toList();
          //             return ListView.builder(
          //                 itemCount: snapshot.data!.snapshot.children.length,
          //                 itemBuilder: (context, int index) {
          //                   return ListTile(
          //                     title: Column(
          //                       children: [
          //                         Text(list[index]['email']),
          //                       ],
          //                     ),
          //                  );
          //                 });
          //           }
          //         })),
          // Expanded(
          //   child: FirebaseAnimatedList(
          //       query: ref,
          //       itemBuilder: (context, snapshot, animation, index) {
          //         return ListTile(
          //           title: Text(snapshot.child('Username').value.toString()),
          //         );
          //       }),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => bio()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
