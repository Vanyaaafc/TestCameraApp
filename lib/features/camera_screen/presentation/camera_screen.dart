import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:test_camera_app/shared/services/camera_service.dart';
import 'package:test_camera_app/shared/services/image_picker_service.dart';
import 'package:test_camera_app/shared/services/media_store_service.dart';
import 'package:test_camera_app/shared/widgets/buttons/photo_button.dart';
import 'package:test_camera_app/shared/widgets/buttons/photo_video_button.dart';
import 'package:test_camera_app/shared/widgets/buttons/record_button.dart';
import 'package:test_camera_app/shared/widgets/camera_control_buttons.dart';
import 'package:test_camera_app/shared/widgets/overlay_image.dart';
import 'package:test_camera_app/shared/widgets/timer.dart';
import 'package:test_camera_app/utils/styles.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraService _cameraService;
  Future<void>? cameraValue;
  bool isRecording = false;
  XFile? _overlayImage;
  bool isPhotoMode = false;

  final ImagePickerService _imagePickerService = ImagePickerService();
  final MediaStoreService _mediaStoreService = MediaStoreService();

  @override
  void initState() {
    super.initState();
    _cameraService = CameraService(widget.cameras);
    int frontCameraIndex = widget.cameras.indexWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
    cameraValue = _cameraService
        .initializeCamera(frontCameraIndex != -1 ? frontCameraIndex : 0);
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child:
                        Text('Camera test task', style: AppStyles.titleStyle),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    FutureBuilder(
                      future: cameraValue,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (_cameraService.controller == null) {
                            return const Center(
                                child: Text("Camera is not available"));
                          }
                          return SizedBox(
                            width: size.width,
                            height: size.height,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: 100,
                                child:
                                    CameraPreview(_cameraService.controller!),
                              ),
                            ),
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                    if (isRecording)
                      const Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 32, top: 16),
                          child: TimerWidget(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          OverlayImage(overlayImage: _overlayImage),
          CameraControlButtons(
            isRecording: isRecording,
            imagePickerService: _imagePickerService,
            cameraService: _cameraService,
            onImagePicked: (image) {
              setState(() {
                _overlayImage = image;
              });
            },
            onCameraToggled: () {
              setState(() {});
            },
          ),
          Visibility(
            visible: !isRecording,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: PhotoVideoButton(
                  isPhotoMode: isPhotoMode,
                  onTap: () {
                    setState(() {
                      isPhotoMode = !isPhotoMode;
                    });
                  },
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: isPhotoMode
                  ? PhotoButton(
                      onPressed: () async {
                        if (_cameraService.controller == null ||
                            !_cameraService.controller!.value.isInitialized) {
                          return;
                        }

                        await cameraValue;
                        final XFile? image = await _cameraService.takePicture();
                        if (image != null) {
                          await _mediaStoreService.saveImage(image);
                        }
                      },
                    )
                  : RecordButton(
                      onPressed: (recording) async {
                        setState(() {
                          isRecording = recording;
                        });

                        if (isRecording) {
                          try {
                            await _cameraService.startVideoRecording();
                          } catch (e) {
                            setState(() => isRecording = false);
                          }
                        } else {
                          try {
                            final XFile? videoFile =
                                await _cameraService.stopVideoRecording();
                            if (videoFile != null) {
                              await _mediaStoreService.saveVideo(videoFile);
                            }
                          } catch (e) {
                            print('Error stopping video recording: $e');
                          }
                        }
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
