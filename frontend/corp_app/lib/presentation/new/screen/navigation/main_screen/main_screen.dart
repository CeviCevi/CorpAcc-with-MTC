import 'dart:async';

import 'package:corp_app/app/app_color/app_color.dart';
import 'package:corp_app/app/app_const.dart';
import 'package:corp_app/combined_recorder.dart';
import 'package:corp_app/data/model/audio_model.dart';
import 'package:corp_app/data/short_db/short_db.dart';
import 'package:corp_app/domain/service/audio_service.dart';
import 'package:corp_app/presentation/new/widget/record_button.dart';
import 'package:corp_app/presentation/old/widget/custom_text_field/custom_text_field.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final CombinedRecorder _recorder = CombinedRecorder();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  bool _isRecording = false;
  bool _isBusy = false;

  String _recordingTime = '00:00';
  String? _recordingPath;
  String? _errorMessage;

  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();

    _nameController.text = 'запись_${DateTime.now().millisecondsSinceEpoch}';
  }

  void _startTimer() {
    _timer?.cancel();
    _elapsedSeconds = 0;

    setState(() {
      _recordingTime = '00:00';
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isRecording) return;

      _elapsedSeconds++;

      final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');

      setState(() {
        _recordingTime = '$minutes:$seconds';
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _toggleRecording() async {
    if (_isBusy) return;

    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage('Введите название записи');
      return;
    }

    setState(() {
      _isBusy = true;
      _errorMessage = null;
      _recordingPath = null;
    });

    try {
      await _recorder.start(name: name);

      if (!mounted) {
        await _recorder.stop();
        return;
      }

      setState(() {
        _isRecording = true;
        _recordingTime = '00:00';
      });

      _startTimer();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isRecording = false;
        _errorMessage = 'Не удалось начать запись:\n$e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    _stopTimer();

    try {
      final path = await _recorder.stop();

      if (!mounted) return;

      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });

      await _createAudio(path);

      if (!mounted) return;

      _showMessage('Аудио успешно отправлено на сервер');

      setState(() {
        _nameController.text =
            'запись_${DateTime.now().millisecondsSinceEpoch}';
        _descriptionController.clear();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isRecording = _recorder.isRecording;
        _errorMessage = 'Не удалось сохранить или отправить аудио:\n$e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _createAudio(String path) async {
    // Загрузка самого файла по полученному ID.
    AudioModel audio = await AudioService.upload(
      audio: AudioModel.empty.copyWith(link: path),
    );

    final audioMeta = AudioModel(
      id: audio.id,
      name: _nameController.text.trim(),
      creatorId: ShortDb.instance.userInSystem.id,
      link: path,
      createAt: DateTime.now().toUtc().toIso8601String(),
      description: _descriptionController.text.trim(),
    );

    await AudioService.updateMeta(audio: audioMeta);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _stopTimer();
    _recorder.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: AppConst.width),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 5),

                    RecordButton(
                      isRecording: _isRecording,
                      onTap: _toggleRecording,
                      name: _nameController.text,
                      time: _recordingTime,
                    ),

                    if (_isBusy) ...[
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: LinearProgressIndicator(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isRecording
                            ? 'Выполняется операция...'
                            : 'Сохранение и отправка аудио...',
                        style: TextStyle(
                          color: AppColor.white.withAlpha(180),
                          fontSize: 13,
                        ),
                      ),
                    ],

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withAlpha(100),
                            ),
                          ),
                          child: SelectableText(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: CustomTextField(
                        controller: _nameController,
                        hint: 'Кошачьи бои',
                        label: 'Название',
                        focusedBorderColor: AppColor.green,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: CustomTextField(
                        maxLines: 3,
                        controller: _descriptionController,
                        hint: 'Встреча для обсуждения закупок новых деталей',
                        label: 'Описание',
                        focusedBorderColor: AppColor.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
