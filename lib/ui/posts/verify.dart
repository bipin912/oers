import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import '../../backend/comparision.dart';

class verify extends StatefulWidget {
  const verify({Key? key}) : super(key: key);

  @override
  _verifyState createState() => _verifyState();
}

class _verifyState extends State<verify> {
  Comparison comparison = Comparison();
  XFile? _image;

  void _getImage() async {
    final image = await comparison.getImageFromCamera();
    setState(() {
      _image = image as XFile?;
    });
  }

  void _checkEligibility() async {
    await comparison.checkEligibility();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Eligibility Checker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? const Text('Take a picture to check eligibility')
                : Image.file(File(_image!.path)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getImage,
              child: const Text('Take a picture'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkEligibility,
              child: const Text('Check Eligibility'),
            ),
          ],
        ),
      ),
    );
  }
}
