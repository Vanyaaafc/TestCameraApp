import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';


class CameraService {
  CameraController? _controller;
  final List<CameraDescription> cameras;
  bool _isFrontCamera = true;

  CameraService(this.cameras);

  Future<void> initializeCamera(int cameraIndex) async {
    try {
      var status = await Permission.camera.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        return;
      }

      _controller = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      await Future.delayed(const Duration(milliseconds: 100));

    } catch (e) {
      _controller = null;
    }
  }

  Future<void> toggleCamera() async {
    if (cameras.length < 2) {
      return;
    }

    _isFrontCamera = !_isFrontCamera;
    int newCameraIndex = cameras.indexWhere(
          (camera) => camera.lensDirection ==
          (_isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
    );

    if (newCameraIndex != -1) {
      await _controller?.dispose();
      _controller = null;
      await initializeCamera(newCameraIndex);
    }
  }

  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      final XFile image = await _controller!.takePicture();
      return image;
    } catch (e) {
      return null;
    }
  }

  Future<void> startVideoRecording() => _controller!.startVideoRecording();
  Future<XFile?> stopVideoRecording() => _controller!.stopVideoRecording();

  CameraController? get controller => _controller;
  bool get isFrontCamera => _isFrontCamera;

  void dispose() => _controller?.dispose();
}