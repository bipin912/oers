import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oers/widgets/button_controller.dart';

import '../ui/firestore/add_firestore_data.dart';

class OrderTypeButton extends StatelessWidget {
  final double value;
  final String title;



  const OrderTypeButton({
    required this.value,
    required this.title,



});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ButtonController>(builder: (buttonController){
      return InkWell(
        onTap: ()=>buttonController.setOrderType(value),
        child: Row(
          children: [
            Radio<double>(
              value: value,
              groupValue: buttonController.orderType,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (double? value){

              },
              activeColor: Theme.of(context).primaryColor,
            ),
            SizedBox(width:10),
            Text(title),
            SizedBox(width: 5,),




          ],
        ),
      );
    });
  }
}
