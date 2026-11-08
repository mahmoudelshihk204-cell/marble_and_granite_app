import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomBotton extends StatelessWidget {
  CustomBotton({
    super.key,
    required this.bottonName,
    this.ontap,
    this.isloading = false,
    required this.containerColor,
    this.fontColor = const Color.fromARGB(255, 251, 250, 250),
  });
  final Color containerColor;
  final Color fontColor;
  final String bottonName;
  VoidCallback? ontap;
  final bool isloading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(16),
          shape: BoxShape.rectangle,
          border: BoxBorder.all(color: Colors.black, width: 1),
        ),
        child: Center(
          child: isloading
              ? SizedBox(
                  height: 25,
                  width: 25,
                  child: const CircularProgressIndicator(color: Colors.black),
                )
              : Text(
                  bottonName,
                  style: TextStyle(
                    color: fontColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
