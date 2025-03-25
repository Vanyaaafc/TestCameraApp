import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_store/flutter_media_store.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_camera_app/shared/widgets/buttons/change_camera_button.dart';
import 'package:test_camera_app/shared/widgets/buttons/gallery_button.dart';
import 'package:test_camera_app/shared/widgets/buttons/record_button.dart';
import 'package:test_camera_app/utils/styles.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  Future<void>? cameraValue;
  bool isRecording = false;
  bool _isFrontCamera = true;
  XFile? _overlayImage;
  Timer? _timer;
  int _recordSeconds = 0;

  final ImagePicker _picker = ImagePicker();
  final FlutterMediaStore _mediaStore = FlutterMediaStore();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _overlayImage = image;
      });
    }
  }

  Future<void> startCamera(int camera) async {
    var status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      return;
    }

    _cameraController = CameraController(
      widget.cameras[camera],
      ResolutionPreset.high,
      enableAudio: false,
    );

    cameraValue = _cameraController!.initialize();
    setState(() {});
  }

  void toggleCamera() {
    if (widget.cameras.length < 2) return;

    _isFrontCamera = !_isFrontCamera;

    int newCameraIndex = widget.cameras.indexWhere(
          (camera) =>
      camera.lensDirection ==
          (_isFrontCamera
              ? CameraLensDirection.front
              : CameraLensDirection.back),
    );

    if (newCameraIndex != -1) {
      startCamera(newCameraIndex);
    }
  }

  Future<void> saveVideoToMediaStore(XFile videoFile) async {
    try {
      final List<int> videoBytes = await videoFile.readAsBytes();
      final String fileName =
          'video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _mediaStore.saveFile(
        fileData: videoBytes,
        mimeType: 'video/mp4',
        rootFolderName: 'Movies',
        folderName: 'TestCameraApp',
        fileName: fileName,
        onSuccess: (String uri, String filePath) {
          print('Video saved to Media Store: URI=$uri, Path=$filePath');
        },
        onError: (String errorMessage) {
          print('Error saving video: $errorMessage');
        },
      );
    } catch (e) {
      print('Exception while saving video: $e');
    }
  }

  void _startTimer() {
    _recordSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _recordSeconds = 0;
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void initState() {
    super.initState();

    int frontCameraIndex = widget.cameras.indexWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    cameraValue = startCamera(frontCameraIndex != -1 ? frontCameraIndex : 0);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _timer?.cancel();
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
                          if (_cameraController == null) {
                            return const Center(
                                child: Text("Camera not available"));
                          }
                          return SizedBox(
                            width: size.width,
                            height: size.height,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: 100,
                                child: CameraPreview(_cameraController!),
                              ),
                            ),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else {
                          return const Center(
                              child: Text("Camera loading error"));
                        }
                      },
                    ),
                    if (isRecording)
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 32, top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(
                                Icons.circle,
                                color: Colors.red,
                                size: 8,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTime(_recordSeconds),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_overlayImage != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: Image.file(
                  File(_overlayImage!.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Align(
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
                        onTap: () {
                          pickImage();
                        },
                      ),
                    const SizedBox(width: 16),
                    const Spacer(),
                    if (!isRecording)
                      ChangeCamera(
                        onPressed: () {
                          toggleCamera();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: RecordButton(
                onPressed: (recording) async {
                  setState(() {
                    isRecording = recording;
                  });

                  if (isRecording) {
                    try {
                      await _cameraController?.startVideoRecording();
                      _startTimer();
                    } catch (e) {
                      setState(() {
                        isRecording = false;
                      });
                      _stopTimer();
                    }
                  } else {
                    try {
                      final XFile? videoFile =
                      await _cameraController?.stopVideoRecording();
                      _stopTimer();
                      if (videoFile != null) {
                        await saveVideoToMediaStore(videoFile);
                      } else {
                        print('No video file to save');
                      }
                    } catch (e) {
                      print('Error stopping video recording: $e');
                      _stopTimer();
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