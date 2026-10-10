import 'package:corp_app/app/app_color/app_color.dart';
import 'package:corp_app/app/data_service.dart';
import 'package:corp_app/app/router_service.dart';
import 'package:corp_app/data/model/audio_model.dart';
import 'package:corp_app/data/short_db/short_db.dart';
import 'package:corp_app/domain/service/audio_service.dart';
import 'package:corp_app/presentation/new/screen/navigation/history_screen/audio_screen/audio_screen.dart';
import 'package:corp_app/presentation/old/widget/custom_text_field/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HistoryScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  List<AudioModel> _audios = [];
  String _query = '';

  List<AudioModel> get _filtered {
    if (_query.trim().isEmpty) return _audios;
    final q = _query.trim().toLowerCase();
    return _audios.where((a) => a.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _load() async {
    final list = await AudioService.getAllByUserId(
      userId: ShortDb.userInSystem.id,
    );
    list.add(AudioModel.empty);
    list.add(AudioModel.empty);
    if (!mounted) return;
    setState(() => _audios = list);
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

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      body: Column(
        children: [
          // поисковая строка
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _searchCtrl,
                    focusedBorderColor: AppColor.green,
                    onSubmitted: (v) => setState(() => _query = v),
                  ),
                ),

                Material(
                  color: AppColor.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _query = _searchCtrl.text),
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

          // лист вью
          Expanded(
            child: _audios.isEmpty
                ? Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: AppColor.green,
                      size: 30,
                    ),
                  )
                : filtered.isEmpty
                ? Column(
                    children: [
                      Spacer(),
                      const Center(child: Text("Записи не найдены")),
                      Spacer(flex: 2),
                    ],
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final audio = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          left: 16,
                          right: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Material(
                              color: AppColor.surface,
                              borderRadius: BorderRadius.circular(15),
                              child: InkWell(
                                onTap: () => RouterService.push(
                                  context,
                                  AudioScreen(audio: audio),
                                ),
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  width: double.infinity,
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        audio.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              "    ${DateService.dateParser(audio.createAt)}",
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColor.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
