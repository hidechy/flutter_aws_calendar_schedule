import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/schedule.dart';

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

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  late List<int> yearOption;
  List<int> monthOption = List.generate(12, (index) => (index + 1));
  late List<int>? dayOption;
  List<int> hourOption = List.generate(24, (index) => index);
  List<int> minuteOption = List.generate(60, (index) => index);

  ///
  void buildDayOption(DateTime selectedDate) {
    List<int> list = [];

    for (int i = 1; i <= DateTime(selectedDate.year, selectedDate.month + 1, 0).day; i++) {
      list.add(i);
    }

    dayOption = list;
  }

  ///
  @override
  void initState() {
    super.initState();

    yearOption = [now.year, now.year + 1];

    selectedDate = now;

    initialIndex = ((now.year - firstDate.year) * 12) + (now.month - firstDate.month);

    pageController = PageController(initialPage: initialIndex);

    buildDayOption(selectedDate);

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
            Expanded(child: createCalendarItem()),
            Container(
              height: 50,
              alignment: Alignment.centerRight,
              child: IconButton(
                splashRadius: 20,
                onPressed: () {
                  selectedStartDate = selectedDate;

                  showDialog(
                    context: context,
                    builder: (context) {
                      return buildAddScheduleDialog();
                    },
                  );
                },
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///
  Widget buildAddScheduleDialog() {
    return SimpleDialog(
      titlePadding: EdgeInsets.zero,
      title: Column(
        children: [
          Row(
            children: [
              IconButton(
                splashRadius: 10,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel),
              ),
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'title',
                  ),
                ),
              ),
              IconButton(
                splashRadius: 10,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.send),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return buildSelectTimeDialog();
                      },
                    );
                  },
                  child: Container(
                    height: 150,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('yyyy').format(selectedStartDate!)),
                        Text(DateFormat('MM/dd').format(selectedStartDate!)),
                        Text(DateFormat('HH:mm').format(selectedStartDate!)),
                      ],
                    ),
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return buildSelectTimeDialog();
                      },
                    );
                  },
                  child: Container(
                    height: 150,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text((selectedEndDate == null) ? '----' : DateFormat('yyyy').format(selectedEndDate!)),
                        Text((selectedEndDate == null) ? '--/--' : DateFormat('MM/dd').format(selectedEndDate!)),
                        Text((selectedEndDate == null) ? '--:--' : DateFormat('HH:mm').format(selectedEndDate!)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///
  Widget buildSelectTimeDialog() {
    return SimpleDialog(
      titlePadding: EdgeInsets.zero,
      title: Column(
        children: [
          Row(
            children: [
              IconButton(
                splashRadius: 10,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel),
              ),
              const Expanded(
                child: Text(
                  '日時を選択',
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                splashRadius: 10,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.send),
              ),
            ],
          ),
          SizedBox(
            height: 150,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 35,
                    onSelectedItemChanged: (int index) {},
                    children: yearOption.map((e) {
                      return Container(
                        height: 35,
                        alignment: Alignment.center,
                        child: Text(e.toString()),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 35,
                    onSelectedItemChanged: (int index) {},
                    children: monthOption.map((e) {
                      return Container(
                        height: 35,
                        alignment: Alignment.center,
                        child: Text(e.toString().padLeft(2, '0')),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 35,
                    onSelectedItemChanged: (int index) {},
                    children: dayOption!.map((e) {
                      return Container(
                        height: 35,
                        alignment: Alignment.center,
                        child: Text(e.toString().padLeft(2, '0')),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 35,
                    onSelectedItemChanged: (int index) {},
                    children: hourOption.map((e) {
                      return Container(
                        height: 35,
                        alignment: Alignment.center,
                        child: Text(e.toString().padLeft(2, '0')),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 35,
                    onSelectedItemChanged: (int index) {},
                    children: minuteOption.map((e) {
                      return Container(
                        height: 35,
                        alignment: Alignment.center,
                        child: Text(e.toString().padLeft(2, '0')),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
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
              selectedDate: selectedDate,
            ),
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
                          children: scheduleList!.map((e) => Text(e.title)).toList(),
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
