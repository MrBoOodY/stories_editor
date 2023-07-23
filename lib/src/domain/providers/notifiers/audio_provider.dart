import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AudioNotifier extends ChangeNotifier {
  double _actualVideoVolume = 1.0;

  /// actual video volume
  double get actualVideoVolume => _actualVideoVolume;
  set actualVideoVolume(double actualVideoVolume) {
    _actualVideoVolume = actualVideoVolume;
    notifyListeners();
  }

  double _virtualVideoVolume = 1.0;

  /// while editing video volume
  double get virtualVideoVolume => _virtualVideoVolume;
  set virtualVideoVolume(double virtualVideoVolume) {
    _virtualVideoVolume = virtualVideoVolume;
    notifyListeners();
  }

  double _actualAudioVolume = 1.0;

  /// actual selected audio volume
  double get actualAudioVolume => _actualAudioVolume;
  set actualAudioVolume(double actualAudioVolume) {
    _actualAudioVolume = actualAudioVolume;
    notifyListeners();
  }

  double _virtualAudioVolume = 1.0;

  /// while selected audio volume
  double get virtualAudioVolume => _virtualAudioVolume;
  set virtualAudioVolume(double virtualAudioVolume) {
    _virtualAudioVolume = virtualAudioVolume;
    notifyListeners();
  }

  String? _actualSelectedAudio;

  /// selected audio volume
  String? get actualSelectedAudio => _actualSelectedAudio;
  set actualSelectedAudio(String? value) {
    _actualSelectedAudio = value;
    notifyListeners();
  }

  String? _virtualSelectedAudio;

  /// selected audio volume
  String? get virtualSelectedAudio =>
      _virtualSelectedAudio ?? _actualSelectedAudio;
  set virtualSelectedAudio(String? value) {
    _virtualSelectedAudio = value;
    notifyListeners();
  }

  pickAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );
      if (result?.paths.isNotEmpty ?? false) {
        virtualSelectedAudio = result!.files.first.path;
        notifyListeners();
      }
    } catch (e) {
      log(e.toString());
    }
  }

  cancelEditing() {
    virtualAudioVolume = actualAudioVolume;
    virtualVideoVolume = actualVideoVolume;
    virtualSelectedAudio = actualSelectedAudio;
  }

  submit() {
    actualAudioVolume = virtualAudioVolume;
    actualVideoVolume = virtualVideoVolume;
    actualSelectedAudio = virtualSelectedAudio;
  }
}
