import 'package:flutter/material.dart';
import 'package:marble_and_granite/Constant/constants.dart';

class CustomContainerItem extends StatelessWidget {
  const CustomContainerItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(height: 90,
    width: 150,
    color: kIconColor,
    child: Center(child: Text('Hello')),);
  }
}