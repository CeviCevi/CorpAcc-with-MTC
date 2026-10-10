import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:corp_app/app/app_color/app_color.dart';
import 'package:corp_app/app/data_service.dart';
import 'package:corp_app/data/model/audio_model.dart';
import 'package:flutter/material.dart';

import '../../../../widget/floating_mini_button.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key, required this.audio});
  final AudioModel audio;

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  // ключ для полного пересоздания LocalAudioPlayer
  Key _playerKey = UniqueKey();
  // колбэк от LocalAudioPlayer — сообщает, есть ли файл
  bool? _fileExists;

  void _reloadPlayer() {
    setState(() {
      _playerKey = UniqueKey();
      _fileExists = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 10,
        children: [
          FloatingMiniButton(icon: Icons.replay_rounded, onTap: _reloadPlayer),
          FloatingMiniButton(
            icon: Icons.download_rounded,
            onTap: () {
              // TODO: скачать файл по widget.audio.link
              // после скачивания — _reloadPlayer();
            },
          ),
        ],
      ),
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              DateService.dateParser(widget.audio.createAt),
              style: TextStyle(color: AppColor.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              widget.audio.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LocalAudioPlayer(
                key: _playerKey,
                path: widget.audio.link,
                onFileStatus: (exists) {
                  if (!mounted) return;
                  if (_fileExists != exists) {
                    setState(() => _fileExists = exists);
                  }
                },
              ),
            ),

            const SizedBox(height: 15),
            Row(
              spacing: 10,
              children: [
                SizedBox(width: 6),
                Expanded(
                  child: AudioButton(label: "Расшифровка", onTap: () {}),
                ),
                Expanded(
                  child: AudioButton(label: "Документ", onTap: () {}),
                ),
                SizedBox(width: 6),
              ],
            ),

            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "описание",
                    style: TextStyle(color: AppColor.textMuted, fontSize: 12),
                  ),
                  Text(
                    widget.audio.description.isEmpty
                        ? ". . ."
                        : widget.audio.description,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AudioButton extends StatelessWidget {
  const new({super.key, required this.label, this.onTap});
  final String label;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.darkGrey,
      borderRadius: .circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: .circular(15),
        child: Container(
          padding: const .symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [Expanded(child: Text(label, textAlign: .center))],
          ),
        ),
      ),
    );
  }
}

class LocalAudioPlayer extends StatefulWidget {
  const LocalAudioPlayer({super.key, required this.path, this.onFileStatus});

  final String path;
  final void Function(bool exists)? onFileStatus;

  @override
  State<LocalAudioPlayer> createState() => _LocalAudioPlayerState();
}

class _LocalAudioPlayerState extends State<LocalAudioPlayer> {
  final AudioPlayer _player = AudioPlayer();

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isReady = false;
  bool _disposed = false;
  bool _fileMissing = false;

  StreamSubscription? _durSub;
  StreamSubscription? _posSub;
  StreamSubscription? _compSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      // ─── проверка файла ───
      final file = File(widget.path);
      final exists = await file.exists();
      widget.onFileStatus?.call(exists);
      if (!exists) {
        if (!mounted) return;
        setState(() => _fileMissing = true);
        return;
      }

      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setSource(DeviceFileSource(widget.path));

      if (_disposed) return;

      _durSub = _player.onDurationChanged.listen((d) {
        if (!mounted) return;
        setState(() => _duration = d);
      });

      _posSub = _player.onPositionChanged.listen((p) {
        if (!mounted) return;
        setState(() => _position = p);
      });

      _compSub = _player.onPlayerComplete.listen((_) {
        if (!mounted) return;
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      });

      if (!mounted) return;
      setState(() => _isReady = true);
    } catch (e) {
      debugPrint('Audio init error: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _durSub?.cancel();
    _posSub?.cancel();
    _compSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (!_isReady || _disposed) return;
    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.resume();
      }
      if (!mounted) return;
      setState(() => _isPlaying = !_isPlaying);
    } catch (e) {
      debugPrint('Audio toggle error: $e');
    }
  }

  Future<void> _seek(Duration d) async {
    if (_disposed) return;
    await _player.seek(d);
    if (!mounted) return;
    setState(() => _position = d);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    // ─── файла нет ───
    if (_fileMissing) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        width: .infinity,
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Файл не загружен',
              style: TextStyle(
                color: AppColor.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Нажмите «Скачать» внизу справа',
              style: TextStyle(color: AppColor.textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final total = _duration.inMilliseconds;
    final current = _position.inMilliseconds.clamp(0, total).toDouble();
    final max = total > 0 ? total.toDouble() : 1.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SizedBox(width: 13),
              IconButton(
                onPressed: _isReady ? _toggle : null,
                padding: EdgeInsets.zero,
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  color: AppColor.greenBlue,
                  size: 40,
                ),
              ),

              const SizedBox(width: 16),
              Text(
                _fmt(_position),
                style: const TextStyle(
                  color: AppColor.textMuted,
                  fontSize: 12,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),

              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                    activeTrackColor: AppColor.accent,
                    inactiveTrackColor: AppColor.accent.withAlpha(
                      (255 * .2).toInt(),
                    ),
                    thumbColor: AppColor.accent,
                    overlayColor: AppColor.accent.withAlpha((255 * .2).toInt()),
                  ),
                  child: Slider(
                    min: 0,
                    max: max,
                    value: current,
                    onChanged: _isReady
                        ? (v) => setState(
                            () => _position = Duration(milliseconds: v.round()),
                          )
                        : null,
                    onChangeEnd: _isReady
                        ? (v) => _seek(Duration(milliseconds: v.round()))
                        : null,
                  ),
                ),
              ),

              Text(
                _fmt(_duration),
                style: const TextStyle(
                  color: AppColor.textMuted,
                  fontSize: 12,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
    );
  }
}
