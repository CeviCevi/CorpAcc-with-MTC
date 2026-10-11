import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DocumentScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const DocumentScreen({super.key, required this.data});

  static const Color _background = Color(0xFFF3F5F7);
  static const Color _green = Color(0xFF239B70);
  static const Color _text = Color(0xFF202A35);
  static const Color _muted = Color(0xFF788391);
  static const Color _border = Color(0xFFE5E9EE);

  String _value(dynamic value) {
    if (value == null) return '';
    if (value is Map) return _value(value['value']);
    return value.toString().trim();
  }

  String _tag(Map record, String tag) {
    final annotations = record['annotations'];

    if (annotations is List) {
      for (final annotation in annotations) {
        if (annotation is Map && annotation['tag'] == tag) {
          return _value(annotation['value']);
        }
      }
    }

    if (record['tag'] == tag) {
      return _value(record['value']);
    }

    return '';
  }

  String _label(String tag) {
    const labels = <String, String>{
      '[name]': 'Имя',
      '[user]': 'Пользователь',
      '[role]': 'Роль',
      '[company_name]': 'Компания',
      '[description]': 'Описание',
      '[speaker_id]': 'ID участника',
      '[agreement]': 'Договорённость',
      '[subject]': 'Предмет',
      '[from_company]': 'От кого',
      '[to_company]': 'Кому',
      '[from_gives]': 'Передаваемые условия',
      '[to_gives]': 'Встречные условия',
      '[conditions]': 'Условия',
      '[deadline]': 'Срок',
      '[status]': 'Статус',
      '[evidence_segment_ids]': 'Подтверждающие фрагменты',
      '[date]': 'Дата',
      '[representative]': 'Представитель',
      '[open_question]': 'Вопрос',
      '[summary]': 'Краткое содержание',
    };

    return labels[tag] ?? tag.replaceAll(RegExp(r'[\[\]]'), '');
  }

  List<Map<String, String>> _fields(
    Map record, {
    bool includeSpeakerId = false,
  }) {
    final annotations = record['annotations'];
    final fields = <Map<String, String>>[];

    if (annotations is List) {
      for (final item in annotations) {
        if (item is! Map) continue;

        final tag = _value(item['tag']);
        final value = _value(item['value']);

        if (value.isEmpty) continue;
        if (tag == '[speaker_id]' && !includeSpeakerId) continue;

        fields.add({'label': _label(tag), 'value': value});
      }
    } else {
      // Поддержка объектов, в которых поля переданы напрямую.
      record.forEach((key, value) {
        if (key == 'annotations' || key == 'tag_vocabulary') return;

        final text = _value(value);
        if (text.isEmpty) return;

        fields.add({'label': _label('[$key]'), 'value': text});
      });
    }

    return fields;
  }

  List<Map> _records(String key) {
    final value = data[key];
    if (value is List) {
      return value.whereType<Map>().toList();
    }
    return [];
  }

  String _recordTitle(Map record, int index, String fallback) {
    final candidates = [
      _tag(record, '[name]'),
      _tag(record, '[company_name]'),
      _tag(record, '[agreement]'),
      _tag(record, '[subject]'),
      _tag(record, '[open_question]'),
      _tag(record, '[description]'),
      _tag(record, '[speaker_id]'),
    ];

    for (final candidate in candidates) {
      if (candidate.isNotEmpty) return candidate;
    }

    return '$fallback ${index + 1}';
  }

  Future<void> _exportPdf() async {
    final pdf = pw.Document();

    final summary = _value(data['summary']);
    final date = _value(data['date']);
    final audio = _value(data['audio']);

    final speakers = _records('speakers');
    final companies = _records('companies');
    final agreements = _records('agreements');
    final questions = _records('open_questions');

    pw.Widget pdfSectionTitle(String title) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 18, bottom: 8),
        child: pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#239B70'),
          ),
        ),
      );
    }

    pw.Widget pdfRecord(Map record, int index, String fallback) {
      final fields = _fields(record, includeSpeakerId: true);

      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 10),
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColor.fromHex('#E5E9EE')),
          borderRadius: pw.BorderRadius.circular(7),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              _recordTitle(record, index, fallback),
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
            if (fields.isNotEmpty) pw.SizedBox(height: 7),
            ...fields.map(
              (field) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: '${field['label']}: ',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#788391'),
                        ),
                      ),
                      pw.TextSpan(text: field['value'] ?? ''),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    void addRecords(
      pw.Widget Function(String) sectionTitle,
      String title,
      List<Map> records,
      String fallback,
    ) {
      if (records.isEmpty) return;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(42),
        build: (context) => [
          pw.Text(
            'ИТОГИ ВСТРЕЧИ',
            style: pw.TextStyle(
              fontSize: 23,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#202A35'),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Аудиозапись: ${audio.isEmpty ? 'Не указана' : audio}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          if (date.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(
                'Дата: $date',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          if (summary.isNotEmpty) ...[
            pdfSectionTitle('Краткое содержание'),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F3F8F5'),
                borderRadius: pw.BorderRadius.circular(7),
              ),
              child: pw.Text(
                summary,
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 4),
              ),
            ),
          ],
          if (speakers.isNotEmpty) ...[
            pdfSectionTitle('Участники'),
            ...speakers.asMap().entries.map(
              (entry) => pdfRecord(entry.value, entry.key, 'Участник'),
            ),
          ],
          if (companies.isNotEmpty) ...[
            pdfSectionTitle('Компании'),
            ...companies.asMap().entries.map(
              (entry) => pdfRecord(entry.value, entry.key, 'Компания'),
            ),
          ],
          if (agreements.isNotEmpty) ...[
            pdfSectionTitle('Договорённости'),
            ...agreements.asMap().entries.map(
              (entry) => pdfRecord(entry.value, entry.key, 'Договорённость'),
            ),
          ],
          if (questions.isNotEmpty) ...[
            pdfSectionTitle('Открытые вопросы'),
            ...questions.asMap().entries.map(
              (entry) => pdfRecord(entry.value, entry.key, 'Вопрос'),
            ),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'meeting_document.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = _value(data['summary']);
    final date = _value(data['date']);
    final audio = _value(data['audio']);

    final speakers = _records('speakers');
    final companies = _records('companies');
    final agreements = _records('agreements');
    final questions = _records('open_questions');

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: _exportPdf,
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 19),
              label: const Text('Экспорт PDF'),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: _green.withAlpha(24),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: _green,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Итоги встречи',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: _text,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Документ по результатам аудиозаписи',
                                style: TextStyle(fontSize: 13, color: _muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: _border),
                    const SizedBox(height: 14),
                    _metadataRow(
                      Icons.audio_file_outlined,
                      'Аудиозапись',
                      audio.isEmpty ? 'Не указана' : audio,
                    ),
                    if (date.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _metadataRow(Icons.calendar_today_outlined, 'Дата', date),
                    ],
                    if (summary.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      const _SectionHeading(
                        title: 'Краткое содержание',
                        icon: Icons.subject_rounded,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F8F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _green.withAlpha(45)),
                        ),
                        child: SelectableText(
                          summary,
                          style: const TextStyle(
                            color: _text,
                            fontSize: 14,
                            height: 1.7,
                          ),
                        ),
                      ),
                    ],
                    if (speakers.isNotEmpty)
                      _buildRecordsSection(
                        title: 'Участники',
                        icon: Icons.people_outline_rounded,
                        records: speakers,
                        fallback: 'Участник',
                      ),
                    if (companies.isNotEmpty)
                      _buildRecordsSection(
                        title: 'Компании',
                        icon: Icons.business_outlined,
                        records: companies,
                        fallback: 'Компания',
                      ),
                    if (agreements.isNotEmpty)
                      _buildRecordsSection(
                        title: 'Договорённости',
                        icon: Icons.handshake_outlined,
                        records: agreements,
                        fallback: 'Договорённость',
                      ),
                    if (questions.isNotEmpty)
                      _buildRecordsSection(
                        title: 'Открытые вопросы',
                        icon: Icons.help_outline_rounded,
                        records: questions,
                        fallback: 'Вопрос',
                      ),
                    const SizedBox(height: 28),
                    const Divider(color: _border),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.verified_outlined, color: _green, size: 17),
                        SizedBox(width: 8),
                        Text(
                          'Сформировано на основе данных встречи',
                          style: TextStyle(fontSize: 12, color: _muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metadataRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _muted),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: _muted),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: _text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsSection({
    required String title,
    required IconData icon,
    required List<Map> records,
    required String fallback,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        _SectionHeading(title: title, icon: icon),
        const SizedBox(height: 14),
        ...records.asMap().entries.map((entry) {
          final record = entry.value;
          final fields = _fields(record);

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _recordTitle(record, entry.key, fallback),
                  style: const TextStyle(
                    color: _text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (fields.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...fields.map(
                    (field) => Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 180,
                            child: Text(
                              field['label']!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _muted,
                              ),
                            ),
                          ),
                          Expanded(
                            child: SelectableText(
                              field['value']!,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                color: _text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeading({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: DocumentScreen._green),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: DocumentScreen._text,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
