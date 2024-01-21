import 'package:flutter/material.dart';
import 'package:oers/backend/facedetection.dart';

import 'package:oers/widgets/round_button.dart';

import '../../backend/comparision.dart';
import 'clusteredlist.dart';

class TieSheet extends StatefulWidget {
  const TieSheet({Key? key}) : super(key: key);

  @override
  State<TieSheet> createState() => _TieSheetState();
}

class _TieSheetState extends State<TieSheet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tiesheet'),

      ),
      body: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          RoundButton(title: 'Click here to see the TieSheet', onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ClusterPage()));
          },),
          SizedBox(
            height: 5,
          ),

          RoundButton(title: 'Verify', onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => FaceRecognitionPage()));
          },),])




    );
  }
}
