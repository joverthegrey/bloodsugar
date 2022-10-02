// datastructure for the bloodsugar entries

class Day {
  DateTime date = DateTime.now();
  double average = 0.0;
  List<Entry> entries = [];

  Day(this.date);

  void addEntry(entry) {
    entries.add(entry);

    // recalculate average
    if (entries.isNotEmpty) {
      var total = 0.0;
      entries.forEach((e) {total += e.value;});
      average = total / entries.length;
    }
  }
}

class Entry
{
  int id;
  DateTime created = DateTime.now();
  double value = 0.0;
  String moment = '';

  Entry(this.id, this.created, this.value, this.moment);
}