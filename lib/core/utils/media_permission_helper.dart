import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app_snackbar.dart';

class MediaPermissionHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Requests Camera permission with appropriate user feedback
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.request();

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (!context.mounted) return false;

    if (status.isPermanentlyDenied) {
      _showPermissionSettingsDialog(
        context,
        title: 'Camera Permission Required',
        message:
            'Camera permission is needed to capture document photos and your profile picture. Please enable camera access in app settings.',
      );
      return false;
    }

    AppSnackBar.showError(
      context,
      'Camera access is required to take photos of documents.',
    );
    return false;
  }

  /// Requests Gallery/Photos permission with appropriate user feedback
  static Future<bool> requestGalleryPermission(BuildContext context) async {
    // On iOS and newer Android, check photos permission
    PermissionStatus status;
    if (Platform.isIOS) {
      status = await Permission.photos.request();
    } else if (Platform.isAndroid) {
      // For Android 13+ (API 33+) Permission.photos is used, for older Android Permission.storage
      status = await Permission.photos.request();
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
    } else {
      status = PermissionStatus.granted;
    }

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (!context.mounted) return false;

    if (status.isPermanentlyDenied) {
      _showPermissionSettingsDialog(
        context,
        title: 'Gallery Permission Required',
        message:
            'Photo gallery access is needed to select document images and profile pictures. Please enable access in app settings.',
      );
      return false;
    }

    AppSnackBar.showError(
      context,
      'Gallery access is required to select document photos.',
    );
    return false;
  }

  /// Picks an image from Camera or Gallery with permission checking
  static Future<File?> pickImage({
    required BuildContext context,
    required ImageSource source,
  }) async {
    final hasPermission = source == ImageSource.camera
        ? await requestCameraPermission(context)
        : await requestGalleryPermission(context);

    if (!hasPermission) return null;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          'Failed to pick image: ${e.toString()}',
        );
      }
    }
    return null;
  }

  /// Displays a dialog when permission is permanently denied to guide user to settings
  static void _showPermissionSettingsDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFE5A600),
              size: 26,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB800),
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Open Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
