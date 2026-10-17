import 'dart:developer';

import 'package:corp_app/app/app_color/app_color.dart';
import 'package:corp_app/app/data_service.dart';
import 'package:corp_app/app/router_service.dart';
import 'package:corp_app/data/model/audio_model.dart';
import 'package:corp_app/data/short_db/short_db.dart';
import 'package:corp_app/domain/service/audio_service.dart';
import 'package:corp_app/domain/service/user_service.dart';
import 'package:corp_app/presentation/new/screen/navigation/history_screen/audio_screen/audio_screen.dart';
import 'package:corp_app/presentation/old/widget/custom_text_field/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  final Map<String, String> _creatorNames = {};
  final Map<String, Future<String>> _creatorRequests = {};

  List<AudioModel> _audios = [];
  String _query = '';
  bool load = false;
  String? _loadError;

  bool get _isCorp => ShortDb.instance.userInSystem.role == 'CORP';

  List<AudioModel> get _filtered {
    final q = _query.trim().toLowerCase();

    if (q.isEmpty) return _audios;

    return _audios.where((audio) {
      final nameMatches = audio.name.toLowerCase().contains(q);

      final creatorMatches =
          _isCorp &&
          (_creatorNames[audio.creatorId]?.toLowerCase().contains(q) ?? false);

      return nameMatches || creatorMatches;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        load = true;
        _loadError = null;
      });
    }

    try {
      final user = ShortDb.instance.userInSystem;

      final List<AudioModel> list;

      if (user.role == 'CORP') {
        list = await AudioService.getAllByCorpId(corpId: user.id);
      } else {
        list = await AudioService.getAllByUserId(userId: user.id);
      }

      if (!mounted) return;

      setState(() {
        _audios = list;
      });

      // Загружаем имена авторов для корпоративного аккаунта.
      if (_isCorp) {
        for (final audio in list) {
          _getCreatorName(audio.creatorId);
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadError = 'Не удалось загрузить записи: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          load = false;
        });
      }
    }
  }

  Future<String> _getCreatorName(String creatorId) {
    final cachedName = _creatorNames[creatorId];

    if (cachedName != null) {
      return Future.value(cachedName);
    }

    // Не отправляем несколько одинаковых запросов одновременно.
    final existingRequest = _creatorRequests[creatorId];

    if (existingRequest != null) {
      return existingRequest;
    }

    final request = _fetchCreatorName(creatorId);
    _creatorRequests[creatorId] = request;

    return request;
  }

  Future<String> _fetchCreatorName(String creatorId) async {
    try {
      final user = await UserService.getUserById(userId: creatorId);
      log(user.toString());
      final name = user.login.trim().isNotEmpty
          ? user.login
          : user.email.trim().isNotEmpty
          ? user.email
          : 'Неизвестный сотрудник';

      _creatorNames[creatorId] = name;

      if (mounted) {
        setState(() {});
      }

      return name;
    } catch (_) {
      return 'Неизвестный сотрудник';
    } finally {
      _creatorRequests.remove(creatorId);
    }
  }

  void _search(String value) {
    setState(() {
      _query = value;
    });
  }

  Widget _buildAudioCard(AudioModel audio) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: () {
                RouterService.push(context, AudioScreen(audio: audio));
              },
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(Icons.audio_file_outlined, color: AppColor.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        audio.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: AppColor.textMuted),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 16, top: 5),
            child: Text(
              DateService.dateParser2(audio.createAt),
              style: const TextStyle(fontSize: 10, color: AppColor.textMuted),
            ),
          ),

          if (_isCorp)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  Expanded(
                    child: FutureBuilder<String>(
                      future: _getCreatorName(audio.creatorId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text(
                            'Загрузка автора...',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColor.textMuted,
                            ),
                          );
                        }

                        return Text(
                          'Автор: ${snapshot.data ?? 'Неизвестный сотрудник'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColor.textMuted,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;

    if (_loadError != null) {
      message = _loadError!;
    } else if (_query.trim().isNotEmpty) {
      message = 'Записи не найдены';
    } else {
      message = 'Записей пока нет';
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 100),
        Icon(
          _loadError != null ? Icons.error_outline : Icons.audio_file_outlined,
          size: 48,
          color: AppColor.textMuted,
        ),
        const SizedBox(height: 12),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColor.textMuted),
            ),
          ),
        ),
        if (_loadError != null) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _searchCtrl,
                      focusedBorderColor: AppColor.green,
                      hint: 'Поиск записи или автора',
                      prefixIcon: const Icon(Icons.search),
                      onChanged: _search,
                      onSubmitted: _search,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: AppColor.transparent,
                    child: InkWell(
                      onTap: () => _search(_searchCtrl.text),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: AppColor.surface.withAlpha(100),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: AppColor.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: load && _audios.isEmpty
                  ? Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: AppColor.green,
                        size: 30,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: filtered.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                return _buildAudioCard(filtered[index]);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
