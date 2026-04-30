import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class ProfileNotifier extends Notifier<File?> {
  @override
  File? build() {
    // Note: build() should return the initial state. 
    // Since _loadSavedImage is async, we start it and return null initially.
    _loadSavedImage();
    return null;
  }

  static const _imageKey = 'profile_image_path';

  Future<void> _loadSavedImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPath = prefs.getString(_imageKey);
      if (savedPath != null) {
        final file = File(savedPath);
        if (await file.exists()) {
          state = file;
        }
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> updateProfileImage(File newImage) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = p.basename(newImage.path);
      final destinationPath = p.join(appDir.path, fileName);
      
      final savedImage = await newImage.copy(destinationPath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_imageKey, savedImage.path);

      state = savedImage;
    } catch (e) {
      // Silent fail
    }
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, File?>(ProfileNotifier.new);
