import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Pick an image from gallery or camera with optimized dimensions
  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 65,
      );
      return file;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Upload an incident photograph.
  // Attempts Firebase Storage first. If Storage bucket is inactive (e.g. Spark plan
  // without Blaze billing), it automatically falls back to a base64 Data URI so
  // photo reporting continues to work 100% without crashing or requiring a credit card.
  Future<String?> uploadIncidentPhoto({
    required XFile file,
    required String incidentId,
  }) async {
    // 1. Try Firebase Cloud Storage
    try {
      final ext = file.name.split('.').last;
      final ref = _storage
          .ref()
          .child('incidents')
          .child(incidentId)
          .child('${DateTime.now().millisecondsSinceEpoch}.$ext');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'incidentId': incidentId},
      );

      UploadTask uploadTask;
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        uploadTask = ref.putData(bytes, metadata);
      } else {
        uploadTask = ref.putFile(File(file.path), metadata);
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (storageError) {
      debugPrint('[StorageService] Firebase Storage bucket unavailable ($storageError). Falling back to direct image payload.');

      // 2. Fallback: Encode compressed image bytes into a data URI
      try {
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      } catch (fallbackError) {
        debugPrint('[StorageService] Fallback encoding failed: $fallbackError');
        throw 'Failed to process image: $fallbackError';
      }
    }
  }
}
