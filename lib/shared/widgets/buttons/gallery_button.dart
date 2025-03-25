import 'package:flutter/material.dart';

class GalleryButton extends StatelessWidget {
  final void Function() onTap;
  const GalleryButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(
          Icons.photo,
          color: Colors.white,
          size: 42,
        ),
      ),
    );
  }
}
