import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:test_camera_app/shared/services/camera_service.dart';
import 'package:test_camera_app/shared/services/image_picker_service.dart';
import 'package:test_camera_app/shared/widgets/buttons/change_camera_button.dart';
import 'package:test_camera_app/shared/widgets/buttons/gallery_button.dart';

class CameraControlButtons extends StatelessWidget {
  final bool isRecording;
  final ImagePickerService imagePickerService;
  final CameraService cameraService;
  final Function(XFile?) onImagePicked;
  final VoidCallback onCameraToggled;

  const CameraControlButtons({
    super.key,
    required this.isRecording,
    required this.imagePickerService,
    required this.cameraService,
    required this.onImagePicked,
    required this.onCameraToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        child: SizedBox(
          height: 75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (!isRecording)
                GalleryButton(
                  onTap: () async {
                    final XFile? image = await imagePickerService.pickImage();
                    onImagePicked(image);
                  },
                ),
              const SizedBox(width: 16),
              const Spacer(),
              if (!isRecording)
                ChangeCamera(
                  onPressed: () async {
                    await cameraService.toggleCamera();
                    onCameraToggled();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}