import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class OverlayImage extends StatelessWidget {
  final XFile? overlayImage;

  const OverlayImage({super.key, this.overlayImage});

  @override
  Widget build(BuildContext context) {
    if (overlayImage == null) {
      return const SizedBox.shrink();
    }
    return Positioned.fill(
      child: Opacity(
        opacity: 0.2,
        child: Image.file(
          File(overlayImage!.path),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}