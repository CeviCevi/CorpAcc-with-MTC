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
}
