import 'package:corp_app/app/app_color/app_color.dart';
import 'package:flutter/material.dart';

class TranscriptionScreen extends StatefulWidget {
  final String transcription;

  const TranscriptionScreen({super.key, required this.transcription});

  @override
  State<TranscriptionScreen> createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  late List<TranscriptionSegment> _segments;
  String _query = '';

  static final RegExp _linePattern = RegExp(
    r'^\[(\d{2}:\d{2}\.\d+)\s*-\s*(\d{2}:\d{2}\.\d+)\]\s*(.+?):\s*(.*)$',
  );

  @override
  void initState() {
    super.initState();
    _segments = _parse(widget.transcription);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TranscriptionSegment> _parse(String source) {
    final result = <TranscriptionSegment>[];

    for (final line in source.split('\n')) {
      final value = line.trim();
      if (value.isEmpty) continue;

      final match = _linePattern.firstMatch(value);

      if (match == null) {
        result.add(
          TranscriptionSegment(
            startTime: '',
            endTime: '',
            speaker: '',
            text: value,
          ),
        );
        continue;
      }

      result.add(
        TranscriptionSegment(
          startTime: match.group(1)!,
          endTime: match.group(2)!,
          speaker: match.group(3)!.trim(),
          text: match.group(4)!.trim(),
        ),
      );
    }

    return result;
  }

  List<TranscriptionSegment> get _filtered {
    final query = _query.trim().toLowerCase();

    if (query.isEmpty) return _segments;

    return _segments.where((segment) {
      return segment.speaker.toLowerCase().contains(query) ||
          segment.text.toLowerCase().contains(query) ||
          segment.startTime.contains(query) ||
          segment.endTime.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        actions: [
          Padding(
            padding: const .only(right: 16),
            child: Text(
              'Реплики: ${filtered.length}',
              style: const TextStyle(color: AppColor.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Поиск
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onSubmitted: (value) {
                      setState(() => _query = value);
                    },
                    onChanged: (value) {
                      setState(() => _query = value);
                    },
                    style: const TextStyle(
                      color: AppColor.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Поиск по транскрипции',
                      hintStyle: const TextStyle(
                        color: AppColor.textMuted,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColor.textMuted,
                      ),
                      filled: true,
                      fillColor: AppColor.surface.withAlpha(100),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColor.green),
                      ),
                    ),
                  ),
                ),
                if (_query.isNotEmpty)
                  Material(
                    color: AppColor.surface.withAlpha(100),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: const SizedBox(
                        height: 48,
                        width: 45,
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: AppColor.textMuted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Список реплик
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Текст не найден',
                      style: TextStyle(color: AppColor.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final segment = filtered[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TranscriptionCard(
                          segment: segment,
                          index: index,
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

class _TranscriptionCard extends StatelessWidget {
  final TranscriptionSegment segment;
  final int index;

  const _TranscriptionCard({required this.segment, required this.index});

  @override
  Widget build(BuildContext context) {
    final isUnknownSpeaker = segment.speaker.isEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColor.green.withAlpha(30),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppColor.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isUnknownSpeaker ? 'Текст' : segment.speaker,
                  style: const TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (segment.startTime.isNotEmpty)
                Text(
                  '${segment.startTime} – ${segment.endTime}',
                  style: const TextStyle(
                    color: AppColor.textMuted,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            segment.text,
            style: const TextStyle(
              color: AppColor.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class TranscriptionSegment {
  final String startTime;
  final String endTime;
  final String speaker;
  final String text;

  const TranscriptionSegment({
    required this.startTime,
    required this.endTime,
    required this.speaker,
    required this.text,
  });
}
