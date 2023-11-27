import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:udemy_aws_calendar_schedule/model/schedule.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime now = DateTime.now();

  List<String> weekName = ['月', '火', '水', '木', '金', '土', '日'];

  late PageController pageController;

  DateTime firstDate = DateTime(2023, 1, 1);

  late int initialIndex;
  int monthDuration = 0;

  late DateTime selectedDate;

  Map<DateTime, List<Schedule>> scheduleMap = {
    DateTime(2023, 11, 5): [
      Schedule(title: 'aaa', startAt: DateTime(2023, 11, 5, 10), endAt: DateTime(2023, 11, 5, 19)),
    ],
    DateTime(2023, 11, 8): [
      Schedule(title: 'bbb', startAt: DateTime(2023, 11, 8, 9), endAt: DateTime(2023, 11, 8, 16)),
    ],
    DateTime(2023, 11, 12): [
      Schedule(title: 'ccc', startAt: DateTime(2023, 11, 12, 6), endAt: DateTime(2023, 11, 12, 9)),
    ],
  };

  ///
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    selectedDate = now;

    initialIndex = ((now.year - firstDate.year) * 12) + (now.month - firstDate.month);

    pageController = PageController(initialPage: initialIndex);

    pageController.addListener(() {
      monthDuration = (pageController.page! - initialIndex).round();

      setState(() {});
    });
  }

  ///
  void selectDate(DateTime cacheDate) {
    selectedDate = cacheDate;
    setState(() {});
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yyyy年M月').format(DateTime(now.year, now.month + monthDuration))),
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
                        style: const TextStyle(color: Colors.white),
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
    return PageView.builder(
      controller: pageController,
      itemBuilder: (context, index) {
        List<Widget> list = [];
        List<Widget> listCache = [];

        DateTime date = DateTime(now.year, now.month + index - initialIndex, 1);

        int monthLastDay = DateTime(date.year, date.month + 1, 1).subtract(const Duration(days: 1)).day;

        for (int i = 0; i < monthLastDay; i++) {
          listCache.add(
            CalendarItem(
                day: i + 1,
                now: now,
                cacheDate: DateTime(date.year, date.month, i + 1),
                scheduleList: scheduleMap[DateTime(date.year, date.month, i + 1)],
                selectDate: selectDate,
                selectedDate: selectedDate),
          );

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
      },
    );
  }
}

// ignore: must_be_immutable
class CalendarItem extends StatelessWidget {
  const CalendarItem({
    super.key,
    required this.day,
    required this.now,
    required this.cacheDate,
    this.scheduleList,
    required this.selectedDate,
    required this.selectDate,
  });

  final int day;
  final DateTime now;
  final DateTime cacheDate;
  final List<Schedule>? scheduleList;
  final DateTime selectedDate;
  final Function selectDate;

  ///
  @override
  Widget build(BuildContext context) {
    bool isToday = (now.difference(cacheDate).inDays == 0) && (now.day == cacheDate.day);

    bool isSelected = selectedDate.difference(cacheDate).inDays == 0 && selectedDate.day == cacheDate.day;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          selectDate(cacheDate);
        },
        child: Container(
          alignment: Alignment.topLeft,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: (isSelected) ? Colors.white.withOpacity(0.1) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: (isToday) ? Colors.blueAccent : Colors.transparent),
                alignment: Alignment.center,
                child: Text(day.toString()),
              ),
              Column(
                children: [
                  (scheduleList == null)
                      ? Container()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: scheduleList!.map((e) {
                            return Text(e.title);
                          }).toList(),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
