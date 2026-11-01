import 'package:flutter/material.dart';
import 'package:marble_and_granite/Constant/constants.dart';


// ignore: must_be_immutable
class CustomBotton extends StatelessWidget {
   CustomBotton({super.key, required this.bottonName, this.ontap,  this.isloading = false});
  final String  bottonName;
  VoidCallback? ontap;
  final bool isloading;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        decoration: BoxDecoration(
          color: kTextColor,
          borderRadius: BorderRadius.circular(16),
          shape: BoxShape.rectangle,
        ),
        child: Center(
          child: isloading ? SizedBox(height:25 , width:25, child: const CircularProgressIndicator(color: Colors.black,))   :   Text(
             bottonName,
            style:  TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
