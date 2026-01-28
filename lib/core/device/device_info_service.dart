import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DeviceInfoService {
  static Future<DeviceData> getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return DeviceData(
          deviceName: "${info.brand} ${info.model}",
          deviceType: "1",
          deviceUniqueId: info.id,
          deviceToken: "temp_fcm_token",
        );
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        return DeviceData(
          deviceName: info.name,
          deviceType: "2",
          deviceUniqueId: info.identifierForVendor ?? "unknown",
          deviceToken: "temp_fcm_token",
        );
      } else {
        return _getDefaultDeviceData();
      }
    } on MissingPluginException catch (e) {
      debugPrint('Plugin not available: $e');
      return _getDefaultDeviceData();
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return _getDefaultDeviceData();
    }
  }

  static DeviceData _getDefaultDeviceData() {
    return DeviceData(
      deviceName: kIsWeb ? "Web" : "Unknown Device",
      deviceType: "0",
      deviceUniqueId: "unknown",
      deviceToken: "temp_fcm_token",
    );
  }
}
class DeviceData {
  final String deviceName;
  final String deviceType;
  final String deviceUniqueId;
  final String deviceToken; 

  DeviceData({
    required this.deviceName,
    required this.deviceType,
    required this.deviceUniqueId,
    required this.deviceToken,
  });
}