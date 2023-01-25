import 'package:flutter/material.dart';

class Tournament extends StatefulWidget {
  const Tournament({Key? key}) : super(key: key);

  @override
  State<Tournament> createState() => _TournamentState();
}

class _TournamentState extends State<Tournament> {
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
            height: 50,
          ),
          SizedBox(height:50,child: ElevatedButton(onPressed: () {

          }, child: Text("Join with Team"),style: ButtonStyle(),)),
          SizedBox(
            height: 20,
          ),
          SizedBox(height:50, child: ElevatedButton(onPressed: () {

          }, child: Text("Join with Randoms")))
        ],
      ),
    );
  }
}
