import 'package:camera/camera.dart';
import 'package:flutter_media_store/flutter_media_store.dart';

class MediaStoreService {
  final FlutterMediaStore _mediaStore = FlutterMediaStore();

  Future<void> saveVideo(XFile videoFile) async {
    try {
      final List<int> videoBytes = await videoFile.readAsBytes();
      final String fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _mediaStore.saveFile(
        fileData: videoBytes,
        mimeType: 'video/mp4',
        rootFolderName: 'Movies',
        folderName: 'TestCameraApp',
        fileName: fileName,
        onSuccess: (uri, path) => print('Video saved: URI=$uri, Path=$path'),
        onError: (error) => print('Error saving video: $error'),
      );
    } catch (e) {
      print('Exception while saving video: $e');
    }
  }

  Future<void> saveImage(XFile imageFile) async {
    try {
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _mediaStore.saveFile(
        fileData: imageBytes,
        mimeType: 'image/jpeg',
        rootFolderName: 'Pictures',
        folderName: 'TestCameraApp',
        fileName: fileName,
        onSuccess: (uri, path) => print('Image saved: URI=$uri, Path=$path'),
        onError: (error) => print('Error saving image: $error'),
      );
    } catch (e) {
      print('Exception while saving image: $e');
    }
  }
}