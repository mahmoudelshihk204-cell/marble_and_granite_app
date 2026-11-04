import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomContainerItem extends StatelessWidget {
  CustomContainerItem({
    super.key,
    required this.containerName,
    this.onTap,
    this.icon,
  });
  final String containerName;
  void Function()? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xffFFFFFF), Color(0xffF5F0E6), Color(0xffEDE3D2)],
          ),

          borderRadius: BorderRadius.circular(28),

          border: Border.all(color: const Color(0xffC5A46D), width: 1.4),

          boxShadow: [
            // Deep floating shadow
            BoxShadow(
              color: const Color(0xff000000).withValues(alpha: 0.16),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, 15),
            ),

            // Golden glow
            BoxShadow(
              color: const Color(0xffC5A46D).withValues(alpha: 0.20),
              blurRadius: 18,
              spreadRadius: -2,
              offset: const Offset(0, 5),
            ),

            // Top highlight
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.9),
              blurRadius: 8,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        height: 100,
        width: 200,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                width: 70,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xffC5A46D),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(icon, size: 25),
                    padding: EdgeInsets.symmetric(horizontal: 0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(width: 1, height: 50, color: const Color(0xffC5A46D)),
                  ),
                  Expanded(
                    child: Text(
                      containerName,
                      softWrap: true,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tuffy',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
