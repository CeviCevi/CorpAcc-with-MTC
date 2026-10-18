import 'dart:io';

class SystemAudioRecorder {
  Process? _process;
  Future<void>? _stopping;

  Future<void> start(String outputPath) async {
    if (_process != null) {
      throw StateError('Системная запись уже запущена');
    }

    final exe = File(
      '${File(Platform.resolvedExecutable).parent.path}'
      '${Platform.pathSeparator}audio_capture.exe',
    );

    if (!await exe.exists()) {
      throw FileSystemException('Не найден WASAPI-компонент', exe.path);
    }

    final process = await Process.start(exe.path, [
      outputPath,
    ], runInShell: false);

    _process = process;

    process.stdout
        .transform(const SystemEncoding().decoder)
        .listen(stdout.write);

    process.stderr
        .transform(const SystemEncoding().decoder)
        .listen(stderr.write);

    process.exitCode.then((_) {
      if (identical(_process, process)) {
        _process = null;
      }
    });
  }

  Future<void> stop() async {
    final existing = _stopping;
    if (existing != null) return existing;

    final process = _process;
    if (process == null) return;

    final operation = () async {
      process.stdin.writeln();
      await process.exitCode;

      if (identical(_process, process)) {
        _process = null;
      }
    }();

    _stopping = operation;

    try {
      await operation;
    } finally {
      _stopping = null;
    }
  }
}
