import 'package:flutter/material.dart';

class PhotoButton extends StatefulWidget {
  final void Function(bool isPhotoMode) onModeChanged;

  const PhotoButton({super.key, required this.onModeChanged});

  @override
  State<PhotoButton> createState() => _PhotoButtonState();
}

class _PhotoButtonState extends State<PhotoButton> {
  bool isVideoMode = false; // По умолчанию фото

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isVideoMode = !isVideoMode;
        });
        widget.onModeChanged(isVideoMode);
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(0),
        backgroundColor: Colors.transparent,
      ),
      child: Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
          color: Colors.transparent,
        ),
        child: Center(
          child: Icon(
            isVideoMode ? Icons.videocam : Icons.photo_camera,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}