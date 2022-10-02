import 'dart:math';
import 'package:blood_sugar/entries.dart';
import 'package:isoweek/isoweek.dart';
import 'package:sprintf/sprintf.dart';

double doubleInRange(Random source, num start, num end) =>
    source.nextDouble() * (end - start) + start;

class GsheetStorage {
  String gsheet_id;

  GsheetStorage(this.gsheet_id);

  List<Day> getDays(Week week) {

    List<Day> days = [];

    // dummy data
    for (int i = 1; i < 8; i++) {
      String daystring = sprintf("202201%02d", [i]);
      var day = Day(DateTime.parse(daystring));
      for (int j = 0; j < 5; j++) {
        var moment = '';
        switch (j) {
          case 0:
            {
              moment = "nu";
            }
            break;
          case 1:
            {
              moment = "vo";
            }
            break;
          case 2:
            {
              moment = "vm";
            }
            break;
          case 3:
            {
              moment = "va";
            }
            break;
          case 4:
            {
              moment = "vs";
            }
            break;
        }
        day.addEntry(Entry(i * 10 + j + 1, DateTime.parse(daystring),
            doubleInRange(new Random(), 4.5, 12.9), moment));
      }
      days.add(day);
    }

    return days;
  }

}