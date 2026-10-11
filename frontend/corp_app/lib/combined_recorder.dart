import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'audio_mixer.dart';
import 'system_audio_recorder.dart';

class CombinedRecorder {
  final AudioRecorder _microphone = AudioRecorder();
  final SystemAudioRecorder _system = SystemAudioRecorder();

  String? _microphonePath;
  String? _systemPath;
  String? _outputPath;

  bool _recording = false;

  bool get isRecording => _recording;

  String? get outputPath => _outputPath;

  Future<void> start({required String name}) async {
    if (_recording) {
      throw StateError('Запись уже идёт');
    }

    if (!await _microphone.hasPermission()) {
      throw StateError('Нет доступа к микрофону');
    }

    // Убираем недопустимые для имени папки символы Windows.
    final safeName = name.trim().replaceAll(
      RegExp(r'[<>:"/\\|?*\x00-\x1F]'),
      '_',
    );

    if (safeName.isEmpty) {
      throw ArgumentError('Введите название записи');
    }

    final documents = await getApplicationDocumentsDirectory();
    final recordingDir = Directory(
      '${documents.path}${Platform.pathSeparator}CorpApp'
      '${Platform.pathSeparator}$safeName',
    );

    await recordingDir.create(recursive: true);

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');

    final separator = Platform.pathSeparator;

    _microphonePath = '${recordingDir.path}${separator}mic_$timestamp.wav';
    _systemPath = '${recordingDir.path}${separator}system_$timestamp.wav';
    _outputPath = '${recordingDir.path}$separator${safeName}_$timestamp.wav';

    await _microphone.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 48000,
        numChannels: 1,
      ),
      path: _microphonePath!,
    );

    try {
      await _system.start(_systemPath!);
    } catch (_) {
      await _microphone.stop();
      rethrow;
    }

    _recording = true;
  }

  Future<String> stop() async {
    if (!_recording) {
      throw StateError('Запись не запущена');
    }

    try {
      await _microphone.stop();
      await _system.stop();

      final mic = _microphonePath;
      final system = _systemPath;
      final output = _outputPath;

      if (mic == null || system == null || output == null) {
        throw StateError('Не заданы пути аудиофайлов');
      }

      return await AudioMixer.mix(
        micPath: mic,
        systemPath: system,
        outputPath: output,
        micVolume: 1.0,
        systemVolume: 1.0,
      );
    } finally {
      _recording = false;
    }
  }

  Future<void> dispose() async {
    if (_recording) {
      await stop();
    }

    await _microphone.dispose();
  }
}
