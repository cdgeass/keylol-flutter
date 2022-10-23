class DateUtils {
  static DateTime convert(String? dateline) {
    if (dateline == null) {
      return DateTime.now();
    }
    return DateTime.fromMillisecondsSinceEpoch(int.parse(dateline) * 1000);
  }

  static String format(String? dateline) {
    if (dateline != null && dateline.contains('-')) {
      return dateline;
    }

    try {
      final datetime = convert(dateline);
      return "${datetime.year.toString()}-${datetime.month.toString().padLeft(2, '0')}-${datetime.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateline ?? '';
    }
  }
}
