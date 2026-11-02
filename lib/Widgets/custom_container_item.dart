import 'package:flutter/material.dart';

class CustomContainerItem extends StatelessWidget {
  const CustomContainerItem({super.key, required this.containerName});
  final String containerName;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 250, 190, 173), 
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xffB8864B), 
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff8B0000).withValues(alpha: 0.12),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      height: 100,
      width: 200,
      child: Center(
        child: Text(
          containerName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tuffy',
          ),
        ),
      ),
    );
  }
}
