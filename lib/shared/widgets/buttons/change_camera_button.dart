import 'package:flutter/material.dart';

class ChangeCamera extends StatelessWidget {
  final void Function() onPressed;
  const ChangeCamera({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(32),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(
          Icons.change_circle_sharp,
          size: 42,
          color: Colors.white,
        ),
      ),
    );
  }
}
