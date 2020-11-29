import 'package:permission_handler/permission_handler.dart';

enum PermissionResult {
  undetermined,
  granted,
  denied,
  restricted,
  permanentlyDenied,
}

class PermissionsUtils {
  Future<PermissionResult> _requestPermission(Permission permission) async {
    final PermissionStatus result = await permission.request();
    return PermissionResult.values[result.index];
  }

  Future<PermissionResult> requestSmsPermission() async {
    return _requestPermission(Permission.sms);
  }

  Future<PermissionResult> checkPermissions() async {
    PermissionStatus status = await Permission.sms.status;
    if (status != PermissionStatus.granted &&
        status != PermissionStatus.permanentlyDenied) {
      return await requestSmsPermission();
    } else if (status == PermissionStatus.permanentlyDenied) {
      bool isGranted = await openAppSettings();
      if (isGranted) {
        status = await Permission.sms.status;
        if (status == PermissionStatus.granted) {
          return PermissionResult.granted;
        }
      }
      return PermissionResult.permanentlyDenied;
    } else {
      return PermissionResult.granted;
    }
  }

  Future<bool> openSettings() async => await openAppSettings();
}
