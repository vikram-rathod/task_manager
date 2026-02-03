import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../features/auth/models/device_data.dart';

class DeviceInfoService {
  static const _uuid = Uuid();

  static Future<DeviceData> getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      final deviceToken = await FirebaseMessaging.instance.getToken() ?? '';

      String deviceUniqueId;
      try {
        deviceUniqueId = _uuid.v4();
      } catch (e) {
        debugPrint('Error getting Firebase Installation ID: $e');
        deviceUniqueId = _uuid.v4();
      }

      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        final androidId = info.id;
        return DeviceData(
          deviceName: "${info.brand} ${info.model}",
          deviceType: "1",
          deviceUniqueId: (androidId.isNotEmpty)
              ? androidId
              : deviceUniqueId,
          deviceToken: deviceToken,
        );
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        final vendorId = info.identifierForVendor;
        return DeviceData(
          deviceName: info.name,
          deviceType: "2",
          deviceUniqueId: (vendorId != null && vendorId.isNotEmpty)
              ? vendorId
              : deviceUniqueId,
          deviceToken: deviceToken,
        );
      } else {
        return _getDefaultDeviceData(deviceUniqueId, deviceToken);
      }
    } on MissingPluginException catch (e) {
      debugPrint('Plugin not available: $e');
      return _getDefaultDeviceData(_uuid.v4(), '');
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
      deviceName: kIsWeb ? "Web" : "Unknown Device",
      deviceType: "0",
      deviceUniqueId: deviceUniqueId.isEmpty ? _uuid.v4() : deviceUniqueId,
      deviceToken: deviceToken,
    );
  }
}