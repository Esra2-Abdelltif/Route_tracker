DateTime calculateFutureTime(int secondsToAdd) {
  // الحصول على الوقت الحالي
  DateTime now = DateTime.now();

  // إضافة الثواني المحددة إلى الوقت الحالي
  Duration duration = Duration(seconds: secondsToAdd);
  DateTime futureTime = now.add(duration);

  return futureTime;
}
