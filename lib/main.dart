import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isoweek/isoweek.dart';
import 'package:sprintf/sprintf.dart';
import './entries.dart';
import './storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('nl_nl'); // initialize nl date locale
    Intl.defaultLocale = "nl_nl"; // set nl as default locale
    return MaterialApp(
      title: 'Blood Sugar',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const OverviewPage(title: 'Bloedsuiker'),
    );
  }
}

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  GsheetStorage storage = GsheetStorage('dummy');
  Week week = Week.current();
  List<Day> days = [];

  _OverviewPageState() {
    days = storage.getDays(week);
  }

  void _previousWeek() {
    setState(() {
      week = week.previous;
    });
  }

  void _nextWeek() {
    setState(() {
      week = week.next;
    });
  }

  void _currentWeek() {
    setState(() {
      week = Week.current();
    });
  }

  bool _outsideLimits(double value) {
    return value < 5 || value > 10;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    days = storage.getDays(week);

    return Scaffold(
      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Row(children: <Widget>[
        Expanded(flex: 3, child: Text(widget.title)),
        Expanded(
            flex: 2,
            child: Row(children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Center(
                      child: IconButton(
                          splashRadius: 1,
                          onPressed: _currentWeek,
                          icon: const Icon(
                            Icons.calendar_month,
                            size: 18,
                          )))),
              Expanded(
                  flex: 1,
                  child: IconButton(
                      splashRadius: 1,
                      onPressed: _previousWeek,
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 18,
                      ))),
              Expanded(
                  flex: 2,
                  child: Center(
                      child: Text(sprintf("W%02d", [week.weekNumber]),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18)))),
              Expanded(
                  flex: 1,
                  child: IconButton(
                      splashRadius: 1,
                      onPressed: _nextWeek,
                      icon: const Icon(Icons.arrow_forward_ios, size: 18))),
            ]))
      ])),
      body: Center(
          child: Column(children: <Widget>[
        Expanded(
            child: ListView.builder(
                itemCount: days.length,
                itemBuilder: (context, index) {
                  var day = days.elementAt(index);
                  print(day.date);
                  print(day.entries.length);

                  return Card(
                      child: ListTile(
                          leading: Icon(
                              _outsideLimits(day.average)
                                  ? Icons.warning
                                  : Icons.water_drop,
                              size: 64,
                              color: Colors.redAccent[700]),
                          trailing: Text(
                            sprintf("gem\n%2.1f", [day.average]),
                            textAlign: TextAlign.center,
                          ),
                          title: Text(DateFormat('EEEE (dd/MM)')
                              .format(day.date)
                              .toLowerCase()),
                          subtitle: Container(
                              height: 52,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: day.entries.length,
                                  itemBuilder: (context, index) {
                                    var entry = day.entries.elementAt(index);
                                    return Container(
                                      padding: EdgeInsets.zero,
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: _outsideLimits(entry.value)
                                                  ? Colors.redAccent
                                                  : Colors.transparent,
                                              width: 3),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(8.0))),
                                      width: 40,
                                      child: Text(
                                        sprintf("%s\n%2.1f",
                                            [entry.moment, entry.value]),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    );
                                  }))));
                })),
        //Container(
        //  height: 150,
        //  child: Center(
        //    child: Text("bla"),
        //  ),
        //)
      ])),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            Navigator.push(
              context,
              MyCustomRoute(
                  builder: (context) =>
                  const InputEntryPage(title: 'Nieuwe meting')),
            );
          });
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class InputEntryPage extends StatelessWidget {
  const InputEntryPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({required WidgetBuilder builder}) : super(builder: builder);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
        position: animation.drive(Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.ease))),
        child: child);
  }
}
