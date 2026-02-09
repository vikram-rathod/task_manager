import 'package:permission_handler/permission_handler.dart';

Future<bool> _requestPermissions() async {
  final statusCamera = await Permission.camera.request();
  final statusStorage = await Permission.storage.request();

  return statusCamera.isGranted && statusStorage.isGranted;
}
