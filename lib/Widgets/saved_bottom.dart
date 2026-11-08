import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SavedBottom extends StatelessWidget {
  SavedBottom({
    super.key,
    required this.bottonName,
    this.ontap,
    this.isloading = false,
    required this.containerColor,
    this.fontColor = const Color.fromARGB(255, 255, 255, 255),
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
        width: 150,
        height: 40,
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(16),
          shape: BoxShape.rectangle,
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
