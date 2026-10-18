import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

class AudioMixer {
  /// Сводит микрофон и системный звук в один стерео WAV.
  ///
  /// micVolume и systemVolume: коэффициенты громкости.
  /// 1.0 = исходная громкость, 0.5 = тише в 2 раза.
  static Future<String> mix({
    required String micPath,
    required String systemPath,
    required String outputPath,
    double micVolume = 1.0,
    double systemVolume = 1.0,
  }) async {
    if (micVolume < 0 || systemVolume < 0) {
      throw ArgumentError('Громкость не может быть отрицательной');
    }

    String quotePath(String path) {
      final normalized = path.replaceAll(r'\', '/');
      return '"$normalized"';
    }

    final command = [
      '-y',
      '-i ${quotePath(micPath)}',
      '-i ${quotePath(systemPath)}',
      '-filter_complex '
          '"[0:a]volume=$micVolume,'
          'aformat=sample_rates=48000:channel_layouts=stereo[mic];'
          '[1:a]volume=$systemVolume,'
          'aformat=sample_rates=48000:channel_layouts=stereo[sys];'
          '[mic][sys]amix=inputs=2:duration=longest:normalize=0,'
          'aformat=sample_rates=48000:channel_layouts=stereo[out]"',
      '-map "[out]"',
      '-c:a pcm_s16le',
      quotePath(outputPath),
    ].join(' ');

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      return outputPath;
    }

    final logs = await session.getLogs();
    final details = logs.map((log) => log.getMessage()).join('\n');

    throw Exception('Не удалось смешать аудио:\n$details');
  }
}
