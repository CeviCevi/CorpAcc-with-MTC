class DateService {
  static String dateParser(String date) {
    try {
      final d = DateTime.parse(date).toLocal();
      return '${d.day.toString().padLeft(2, '0')}.'
          '${d.month.toString().padLeft(2, '0')}.'
          '${d.year}';
    } catch (_) {
      return "18.11.2000";
    }
  }

  static String dateParser2(String value) {
    try {
      if (value == null || value.isEmpty) return '';

      final date = DateTime.tryParse(value);
      if (date == null) return value;

      final d = date.toLocal();

      return '${d.day.toString().padLeft(2, '0')}.'
          '${d.month.toString().padLeft(2, '0')}.'
          '${d.year} '
          '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return "date";
    }
  }
}
