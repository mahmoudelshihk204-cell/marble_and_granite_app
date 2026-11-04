
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin {

  final MobileScannerController controller =
      MobileScannerController();

  bool isScanned = false;

  late AnimationController animationController;
  late Animation<double> scanAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    scanAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff151515),

      appBar: AppBar(
        title: const Text(
          'Scan Product',
          style: TextStyle(
            color: Color(0xffC5A46D),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: .5),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                'Scan Your Product',
                style: TextStyle(
                  color: Color(0xffC5A46D),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tuffy',
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Place the barcode inside the frame',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 35),

              // Camera Scanner Frame
              AspectRatio(
                aspectRatio: 1,

                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xffC5A46D),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xffC5A46D)
                            .withValues(alpha: 0.2),
                        blurRadius: 25,
                        spreadRadius: 3,
                      ),
                    ],
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23),

                    child: LayoutBuilder(
                      builder: (context, constraints) {

                        return Stack(
                          fit: StackFit.expand,
                          children: [

                            // Camera
                            MobileScanner(
                              controller: controller,
                              onDetect: (capture) {
                                if (isScanned) return;

                                final barcodes = capture.barcodes;

                                if (barcodes.isNotEmpty) {
                                  final String? code =
                                      barcodes.first.rawValue;

                                  if (code != null) {
                                    isScanned = true;
                                    Navigator.pop(context, code);
                                  }
                                }
                              },
                            ),

                            // Moving Scan Line
                            AnimatedBuilder(
                              animation: scanAnimation,
                              builder: (context, child) {

                                final double topPosition =
                                    12 +
                                    (constraints.maxHeight - 24) *
                                        scanAnimation.value;

                                return Positioned(
                                  top: topPosition,
                                  left: 12,
                                  right: 12,

                                  child: Container(
                                    height: 3,

                                    decoration: BoxDecoration(
                                      color: const Color(0xffE5BD76),
                                      borderRadius:
                                          BorderRadius.circular(10),

                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xffE5BD76)
                                              .withValues(alpha: 0.8),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: Color(0xffC5A46D),
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Scanning...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
