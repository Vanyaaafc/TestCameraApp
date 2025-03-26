import 'package:flutter/material.dart';

class PhotoVideoButton extends StatelessWidget {
  final void Function() onTap;
  final bool isPhotoMode;

  const PhotoVideoButton({
    super.key,
    required this.onTap,
    required this.isPhotoMode,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          color: Colors.transparent,
        ),
        child: Center(
          child: Icon(
            isPhotoMode ? Icons.videocam : Icons.photo_camera,
            size: 22,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}