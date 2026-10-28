import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Pick an image from gallery or camera
  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      return file;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Upload an incident photograph to Firebase Storage
  Future<String?> uploadIncidentPhoto({
    required XFile file,
    required String incidentId,
  }) async {
    try {
      final ext = file.name.split('.').last;
      final ref = _storage
          .ref()
          .child('incidents')
          .child(incidentId)
          .child('${DateTime.now().millisecondsSinceEpoch}.$ext');

      SettableMetadata metadata = SettableMetadata(
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
    } catch (e) {
      debugPrint('Storage upload error: $e');
      throw 'Failed to upload image: $e';
    }
  }
}
