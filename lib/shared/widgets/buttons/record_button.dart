import 'package:flutter/material.dart';

class RecordButton extends StatefulWidget {
  final void Function(bool isRecording) onPressed;

  const RecordButton({super.key, required this.onPressed});

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool isRecording = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isRecording = !isRecording;
        });
        widget.onPressed(isRecording);
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
          child: Container(
            width: isRecording ? 30 : 65,
            height: isRecording ? 30 : 65,
            decoration: BoxDecoration(
              shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: isRecording ? BorderRadius.circular(4) : null,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}