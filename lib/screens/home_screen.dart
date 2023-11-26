import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  DateTime now = DateTime.now();

  ///
  @override
  Widget build(BuildContext context) {
    List<String> weekName = ['月', '火', '水', '木', '金', '土', '日'];

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy年M月').format(now)),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 30,
              color: Theme.of(context).primaryColor,
              child: Row(
                children: weekName.map((e) {
                  return Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        e,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: createCalendarItem(),
            ),
          ],
        ),
      ),
    );
  }

  ///
  Widget createCalendarItem() {
    List<Widget> list = [];
    List<Widget> listCache = [];

    int monthLastDay = DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1)).day;

    DateTime date = DateTime(now.year, now.month, 1);

    for (int i = 0; i < monthLastDay; i++) {
      listCache.add(CalendarItem(day: i + 1));

      int repeatNumber = 7 - listCache.length;

      if (date.add(Duration(days: i)).weekday == 7) {
        if (i < 7) {
          listCache.insertAll(0, List.generate(repeatNumber, (index) => Expanded(child: Container())));
        }

        list.add(Expanded(child: Row(children: listCache)));
        listCache = [];
      } else if (i == monthLastDay - 1) {
        listCache.addAll(List.generate(repeatNumber, (index) => Expanded(child: Container())));
        list.add(Expanded(child: Row(children: listCache)));
      }
    }

    return Column(children: list);
  }
}

class CalendarItem extends StatelessWidget {
  const CalendarItem({super.key, required this.day, required this.now});

  final int day;
  final DateTime now;

  ///
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.topLeft,
        child: Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          child: Text(day.toString()),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
      ),
    );
  }
}
