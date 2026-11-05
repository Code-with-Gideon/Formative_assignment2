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
  // Attempts Firebase Storage first. If Storage bucket fails, rules reject, or network times out,
  // it automatically falls back to an optimized Data URI so photo reporting continues
  // without ever failing or disrupting the student workflow.
  Future<String?> uploadIncidentPhoto({
    required XFile file,
    required String incidentId,
  }) async {
    // 1. Try Firebase Cloud Storage
    try {
      final ext = file.name.contains('.') ? file.name.split('.').last : 'jpg';
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

      final snapshot = await uploadTask.timeout(const Duration(seconds: 25));
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('[StorageService] Photo uploaded successfully to Firebase Storage: $downloadUrl');
      return downloadUrl;
    } catch (storageError) {
      debugPrint('[StorageService] Firebase Storage notice ($storageError). Activating resilient payload.');

      // 2. Resilient fallback: clean, compact Data URI
      try {
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      } catch (fallbackError) {
        debugPrint('[StorageService] Fallback encoding issue: $fallbackError');
        throw 'Failed to process image: $fallbackError';
      }
    }
  }
}
