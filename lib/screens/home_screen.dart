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
  TextEditingController titleController = TextEditingController();

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

  DateTime? selectedStartTime;
  DateTime? selectedEndTime;

  late List<int> yearOption;
  List<int> monthOption = List.generate(12, (index) => (index + 1));
  late List<int>? dayOption;
  List<int> hourOption = List.generate(24, (index) => index);
  List<int> minuteOption = List.generate(60, (index) => index);

  bool isSettingStartTime = true;

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
                      child: Text(e, style: const TextStyle(color: Colors.white)),
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
                onPressed: () async {
                  selectedStartTime = selectedDate;

                  await showDialog(
                    context: context,
                    builder: (context) => buildAddScheduleDialog(),
                  );

                  titleController.clear();

                  setState(() {});
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
    return StatefulBuilder(builder: (context, setState) {
      return SimpleDialog(
        titlePadding: EdgeInsets.zero,
        title: Column(
          children: [
            Row(
              children: [
                IconButton(
                  splashRadius: 10,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel),
                ),
                Expanded(
                  child: TextField(
                    controller: titleController,
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'title'),
                  ),
                ),
                IconButton(
                  splashRadius: 10,
                  onPressed: () {
                    if (!validate()) {
                      return;
                    }

                    var keyDate = DateTime(selectedStartTime!.year, selectedStartTime!.month, selectedStartTime!.day);

                    if (scheduleMap.containsKey(keyDate)) {
                      scheduleMap[keyDate]!.add(
                        Schedule(title: titleController.text, startAt: selectedStartTime!, endAt: selectedEndTime!),
                      );
                    } else {
                      scheduleMap[keyDate] = [
                        Schedule(title: titleController.text, startAt: selectedStartTime!, endAt: selectedEndTime!)
                      ];
                    }

                    selectedEndTime = null;

                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      buildDayOption(selectedDate);
                      isSettingStartTime = true;

                      await showDialog(
                        context: context,
                        builder: (context) => buildSelectTimeDialog(),
                      );

                      setState(() {});
                    },
                    child: Container(
                      height: 150,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat('yyyy').format(selectedStartTime!)),
                          Text(DateFormat('MM/dd').format(selectedStartTime!)),
                          Text(DateFormat('HH:mm').format(selectedStartTime!)),
                        ],
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      buildDayOption(selectedDate);
                      isSettingStartTime = false;

                      //こんな書き方あるんだな
                      selectedEndTime ??= selectedStartTime;

                      await showDialog(
                        context: context,
                        builder: (context) => buildSelectTimeDialog(),
                      );

                      setState(() {});
                    },
                    child: Container(
                      height: 150,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text((selectedEndTime == null) ? '----' : DateFormat('yyyy').format(selectedEndTime!)),
                          Text((selectedEndTime == null) ? '--/--' : DateFormat('MM/dd').format(selectedEndTime!)),
                          Text((selectedEndTime == null) ? '--:--' : DateFormat('HH:mm').format(selectedEndTime!)),
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
    });
  }

  ///
  Widget buildSelectTimeDialog() {
    return StatefulBuilder(builder: (context, setState) {
      return SimpleDialog(
        titlePadding: EdgeInsets.zero,
        title: Column(
          children: [
            Row(
              children: [
                IconButton(
                  splashRadius: 10,
                  onPressed: () => Navigator.pop(context),
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
                  onPressed: () => Navigator.pop(context),
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
                      onSelectedItemChanged: (int index) {
                        if (isSettingStartTime) {
                          selectedStartTime = DateTime(yearOption[index], selectedStartTime!.month,
                              selectedStartTime!.day, selectedStartTime!.hour, selectedStartTime!.minute);
                        } else {
                          selectedEndTime = DateTime(yearOption[index], selectedEndTime!.month, selectedEndTime!.day,
                              selectedEndTime!.hour, selectedEndTime!.minute);
                        }
                      },
                      scrollController: FixedExtentScrollController(
                        initialItem: yearOption.indexOf(
                          (isSettingStartTime) ? selectedStartTime!.year : selectedEndTime!.year,
                        ),
                      ),
                      children: yearOption.map((e) {
                        return Container(height: 35, alignment: Alignment.center, child: Text(e.toString()));
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 35,
                      onSelectedItemChanged: (int index) {
                        if (isSettingStartTime) {
                          selectedStartTime = DateTime(selectedStartTime!.year, monthOption[index],
                              selectedStartTime!.day, selectedStartTime!.hour, selectedStartTime!.minute);

                          buildDayOption(selectedStartTime!);
                        } else {
                          selectedEndTime = DateTime(selectedEndTime!.year, monthOption[index], selectedEndTime!.day,
                              selectedEndTime!.hour, selectedEndTime!.minute);

                          buildDayOption(selectedEndTime!);
                        }

                        setState(() {});
                      },
                      scrollController: FixedExtentScrollController(
                        initialItem: monthOption.indexOf(
                          (isSettingStartTime) ? selectedStartTime!.month : selectedEndTime!.month,
                        ),
                      ),
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
                      onSelectedItemChanged: (int index) {
                        if (isSettingStartTime) {
                          selectedStartTime = DateTime(selectedStartTime!.year, selectedStartTime!.month,
                              dayOption![index], selectedStartTime!.hour, selectedStartTime!.minute);
                        } else {
                          selectedEndTime = DateTime(selectedEndTime!.year, selectedEndTime!.month, dayOption![index],
                              selectedEndTime!.hour, selectedEndTime!.minute);
                        }
                      },
                      scrollController: FixedExtentScrollController(
                        initialItem: dayOption!.indexOf(
                          (isSettingStartTime) ? selectedStartTime!.day : selectedEndTime!.day,
                        ),
                      ),
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
                      onSelectedItemChanged: (int index) {
                        if (isSettingStartTime) {
                          selectedStartTime = DateTime(selectedStartTime!.year, selectedStartTime!.month,
                              selectedStartTime!.day, hourOption[index], selectedStartTime!.minute);
                        } else {
                          selectedEndTime = DateTime(selectedEndTime!.year, selectedEndTime!.month,
                              selectedEndTime!.day, hourOption[index], selectedEndTime!.minute);
                        }
                      },
                      scrollController: FixedExtentScrollController(
                        initialItem: hourOption.indexOf(
                          (isSettingStartTime) ? selectedStartTime!.hour : selectedEndTime!.hour,
                        ),
                      ),
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
                      onSelectedItemChanged: (int index) {
                        if (isSettingStartTime) {
                          selectedStartTime = DateTime(selectedStartTime!.year, selectedStartTime!.month,
                              selectedStartTime!.day, selectedStartTime!.hour, minuteOption[index]);
                        } else {
                          selectedEndTime = DateTime(selectedEndTime!.year, selectedEndTime!.month,
                              selectedEndTime!.day, selectedEndTime!.hour, minuteOption[index]);
                        }
                      },
                      scrollController: FixedExtentScrollController(
                        initialItem: minuteOption
                            .indexOf((isSettingStartTime) ? selectedStartTime!.minute : selectedEndTime!.minute),
                      ),
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
    });
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
              editSchedule: editSchedule,
              deleteSchedule: deleteSchedule,
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

  ///
  bool validate() {
    if (selectedEndTime == null) {
      debugPrint('end time is null');
      return false;
    } else if (selectedStartTime!.isAfter(selectedEndTime!)) {
      debugPrint('start & end wrong');
      return false;
    }

    return true;
  }

  ///
  Future<void> editSchedule({required int index, required Schedule selectedSchedule}) async {
    selectedStartTime = selectedSchedule.startAt;
    selectedEndTime = selectedSchedule.endAt;
    titleController.text = selectedSchedule.title;

    final result = await showDialog(context: context, builder: (context) => buildAddScheduleDialog());

    if (result == true) {
      scheduleMap[
              DateTime(selectedSchedule.startAt.year, selectedSchedule.startAt.month, selectedSchedule.startAt.day)]!
          .removeAt(index);
    }

    setState(() {});
  }

  ///
  void deleteSchedule({required int index, required Schedule selectedSchedule}) {
    scheduleMap[DateTime(selectedSchedule.startAt.year, selectedSchedule.startAt.month, selectedSchedule.startAt.day)]!
        .removeAt(index);

    setState(() {});
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
    required this.editSchedule,
    required this.deleteSchedule,
  });

  final int day;
  final DateTime now;
  final DateTime cacheDate;
  final List<Schedule>? scheduleList;
  final DateTime selectedDate;
  final Function selectDate;
  final Function editSchedule;
  final Function deleteSchedule;

  ///
  @override
  Widget build(BuildContext context) {
    bool isToday = (now.difference(cacheDate).inDays == 0) && (now.day == cacheDate.day);

    bool isSelected = selectedDate.difference(cacheDate).inDays == 0 && selectedDate.day == cacheDate.day;

    return Expanded(
      child: GestureDetector(
        onTap: () => selectDate(cacheDate),
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
                          children: scheduleList!
                              .asMap()
                              .entries
                              .map(
                                (e) => GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return CupertinoAlertDialog(
                                          title: Text(e.value.title),
                                          actions: [
                                            CupertinoDialogAction(
                                              child: const Text('edit'),
                                              onPressed: () {
                                                Navigator.pop(context);

                                                editSchedule(index: e.key, selectedSchedule: e.value);
                                              },
                                            ),
                                            CupertinoDialogAction(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                deleteSchedule(index: e.key, selectedSchedule: e.value);
                                              },
                                              isDestructiveAction: true,
                                              child: const Text('delete'),
                                            ),
                                            CupertinoDialogAction(
                                              child: const Text('cancel'),
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: SizedBox(width: double.infinity, child: Text(e.value.title)),
                                ),
                              )
                              .toList(),
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
