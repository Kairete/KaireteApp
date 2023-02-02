import 'package:jiffy/jiffy.dart';
import 'package:timeago/timeago.dart' as timeago;

class TimeManager {
  static TimeManager? _instance;

  TimeManager._();

  static TimeManager get instance => _instance ??= TimeManager._();

  String getAgoTime({dynamic time}) {
    if (time == null) {
      return '';
    }
    var targetTime = time;
    if (time is String) {
      targetTime = DateTime.parse(time);
    }
    return timeago.format(targetTime);
  }

  String convertFromTimeStamp({required int timestamp, String? format}) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var dateString = Jiffy(date).format(format ?? "MMM do, yyyy - hh:mm");
    return dateString;
  }
}
