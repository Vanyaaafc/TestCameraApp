import 'package:flutter/material.dart';

class PhotoVideoButton extends StatelessWidget {
  final void Function() onTap;
  final Icon icon;
  const PhotoVideoButton({super.key, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: icon
      ),
    );
  }
}
