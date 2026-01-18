class YearUtils {
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  static int getTotalDaysInYear(int year) {
    return isLeapYear(year) ? 366 : 365;
  }

  static int getCurrentDayOfYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    return now.difference(startOfYear).inDays + 1;
  }

  static int getCurrentYear() {
    return DateTime.now().year;
  }

  static int getPassedDays() {
    return getCurrentDayOfYear() - 1;
  }

  static int getRemainingDays() {
    final year = getCurrentYear();
    final totalDays = getTotalDaysInYear(year);
    final currentDay = getCurrentDayOfYear();
    return totalDays - currentDay;
  }
}
