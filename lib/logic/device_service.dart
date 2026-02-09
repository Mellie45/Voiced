import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceService {
  final _storage = const FlutterSecureStorage();
  final _deviceInfo = DeviceInfoPlugin();

  static const String _storageKey = 'vocal_eyes_device_token';

  Future<String?> getUniqueDeviceIdentifier() async {
    try {
      // Check keychain for existing token
      String? savedId = await _storage.read(key: _storageKey);

      if (savedId != null && savedId.isNotEmpty) {
        debugPrint('Found existing persistent device ID: $savedId');
        return savedId;
      }
      // If no saved token, fetch the hardware-level ID
      String hardwareId = '';

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        hardwareId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        hardwareId = iosInfo.identifierForVendor ?? 'Unknown_ios_device';
      }
      // Save this ID into Secure Storage so it persists
      await _storage.write(key: _storageKey, value: hardwareId);

      debugPrint('Generated and saved new device ID: $hardwareId');
      return hardwareId;


    } catch (e) {
      debugPrint('Error generating device ID: $e');
      return 'fallback_id_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Already flagged as "used" in your database.
  Future<bool> hasAlreadyUsedFreeTier() async {
    try {
      // 1. Get the persistent hardware ID (from Keychain/Android ID)
      String? deviceId = await getUniqueDeviceIdentifier();

      // 2. Look for this device in a specific 'device_limits' collection
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('device_limits')
          .doc(deviceId)
          .get();

      // 3. If the document exists, check the flag
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['hasClaimedFreeTrial'] ?? false;
      }

      // 4. If no document exists, the device is "clean"
      return false;
    } catch (e) {
      debugPrint("Error checking device limit: $e");
      // Fallback: If the network fails, we usually let them through to
      // avoid a broken user experience, or you can return true to be strict.
      return false;
    }
  }

  Future<void> tagDeviceAsUsed() async {
    try {
      String? deviceId = await getUniqueDeviceIdentifier();

      // We use set() with merge: true to create or update the record
      await FirebaseFirestore.instance
          .collection('device_limits')
          .doc(deviceId)
          .set({
        'hasClaimedFreeTrial': true,
        'lastUsed': FieldValue.serverTimestamp(),
        'deviceId': deviceId, // Good for manual cross-referencing
      }, SetOptions(merge: true));

      debugPrint('Device $deviceId has been tagged as having used free tier.');
    } catch (e) {
      debugPrint('Error tagging device: $e');
    }
  }
}
