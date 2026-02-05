import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../features/auth/models/device_data.dart';

class DeviceInfoService {
  static const _uuid = Uuid();

  static Future<DeviceData> getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
      final deviceUniqueId = _uuid.v4();

      // Web platform
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        return DeviceData(
          deviceName: "${webInfo.browserName} on ${webInfo.platform}",
          deviceType: "3", // Web
          deviceUniqueId: deviceUniqueId,
          deviceToken: deviceToken,
        );
      }

      // Android platform
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await deviceInfo.androidInfo;
        return DeviceData(
          deviceName: "${info.brand} ${info.model}",
          deviceType: "1",
          deviceUniqueId: info.id.isNotEmpty ? info.id : deviceUniqueId,
          deviceToken: deviceToken,
        );
      }

      // iOS platform
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await deviceInfo.iosInfo;
        final vendorId = info.identifierForVendor ?? '';
        return DeviceData(
          deviceName: info.name,
          deviceType: "2",
          deviceUniqueId: vendorId.isNotEmpty ? vendorId : deviceUniqueId,
          deviceToken: deviceToken,
        );
      }

      // Fallback
      return _getDefaultDeviceData(deviceUniqueId, deviceToken);
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return _getDefaultDeviceData(_uuid.v4(), '');
    }
  }

  static DeviceData _getDefaultDeviceData(
      String deviceUniqueId,
      String deviceToken,
      ) {
    return DeviceData(
      deviceName: kIsWeb ? "Web Browser" : "Unknown Device",
      deviceType: kIsWeb ? "3" : "0",
      deviceUniqueId: deviceUniqueId,
      deviceToken: deviceToken,
    );
  }
}