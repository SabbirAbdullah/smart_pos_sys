import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


Future<bool> requestCameraPermission(BuildContext context) async {
  final status = await Permission.camera.status;
  if (status.isGranted) return true;


  final result = await Permission.camera.request();


  if (result.isGranted) return true;


// show dialog to open settings
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Camera Permission Required'),
      content: const Text('Camera permission is needed to scan QR codes.'),
      actions: [
        TextButton(
          onPressed: () {
            openAppSettings();
            Navigator.of(context).pop();
          },
          child: const Text('Open Settings'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );


  return false;
}