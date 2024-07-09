import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qlmoney/data/event.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart'; // Thêm thư viện uuid

import 'bottom_navigation_bar.dart';

class RemindPage extends StatefulWidget {
  const RemindPage({Key? key}) : super(key: key);

  @override
  State<RemindPage> createState() => _RemindPageState();
}

class _RemindPageState extends State<RemindPage> {
  DateTime today = DateTime.now();
  DateTime? selectedDay;
  Map<DateTime, List<Event>> events = {};
  TextEditingController _eventController = TextEditingController();
  late final ValueNotifier<List<Event>> selectedEvents;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    selectedDay = today;
    selectedEvents = ValueNotifier(_getEventsForDay(selectedDay!));
    getEventsFromDatabase();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  void getEventsFromDatabase() async {
    final user = _auth.currentUser;
    if (user != null) {
      DatabaseReference eventsRef =
          _database.reference().child('users').child(user.uid).child('events');
      try {
        DataSnapshot snapshot = await eventsRef.get();
        if (snapshot.value != null) {
          Map<dynamic, dynamic> eventsData =
              snapshot.value as Map<dynamic, dynamic>;
          Map<DateTime, List<Event>> eventsMap = {}; // Sử dụng DateTime làm key
          eventsData.forEach((key, value) {
            try {
              String eventId = key; // Sử dụng id làm key
              String title = value['title'];
              DateTime date = DateTime.parse(
                  value['date']); // Chuyển đổi date thành DateTime
              Event event = Event(eventId, title, date);
              eventsMap[date] = [event];
            } catch (e) {
              print('Error parsing event: $e');
            }
          });

          setState(() {
            events = eventsMap;
            selectedEvents.value = _getEventsForDay(selectedDay!);
          });
        } else {
          print('No events data available');
        }
      } catch (e) {
        print('Error getting events: $e');
      }
    }
  }


  void _onDaySelected(DateTime day, DateTime focusedDay) {
    if (!isSameDay(selectedDay, day)) {
      setState(() {
        selectedDay = day;
        today = focusedDay;
        selectedEvents.value = _getEventsForDay(day);
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    List<Event> eventsForDay = [];
    events.forEach((eventDay, eventList) {
      if (isSameDay(eventDay, day)) {
        eventsForDay.addAll(eventList);
      }
    });
    return eventsForDay;
  }

  void _saveEventToDatabase(Event event) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        String eventId = Uuid().v4(); // Tạo id ngẫu nhiên
        DatabaseReference eventRef = _database
            .reference()
            .child('users')
            .child(user.uid)
            .child('events')
            .child(eventId); // Sử dụng id ngẫu nhiên
        await eventRef.set({
          'id': eventId, // Lưu trường ID vào cơ sở dữ liệu
          'title': event.title,
          'date': event.date.toIso8601String(),
        });

        // Thêm sự kiện vào danh sách cho ngày tương ứng
        events.update(event.date, (existingEvents) {
          existingEvents.add(event);
          return existingEvents;
        }, ifAbsent: () => [event]);

        print('Event saved to Realtime Database');
      }
    } catch (e) {
      print('Error saving event: $e');
    }
  }

  // Hien thi hop thoai xác nhận xóa
  void _showConfirmDelete(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 215, 236, 254),
          title: const Text(
            "Delete confirm",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          content: Text("Do you want to delete ${event.title}"),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Cancel",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "Delete",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _deleteEventFromDatabase(event);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Ham xoa
  void _deleteEventFromDatabase(Event event) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        DatabaseReference eventRef = _database
            .reference()
            .child('users')
            .child(user.uid)
            .child('events')
            .child(event.id);
        await eventRef.remove();

        setState(() {
          events[event.date]?.remove(event);
          selectedEvents.value = _getEventsForDay(selectedDay!);
        });

        print('Event deleted from Firebase');
      }
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  // show Edit form
  void _showEditDialog(BuildContext context, Event event) {
    TextEditingController _controller =
        TextEditingController(text: event.title);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              const Color.fromARGB(255, 255, 253, 245), // Đặt màu nền ở đây
          title: const Text(
            "Edit Remind",
            style: TextStyle(
                color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Enter the new value",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Cancel",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "Edit",
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                setState(() {
                  event.title = _controller.text;
                });

                // Cập nhật sự kiện trong cơ sở dữ liệu Firebase
                _updateEventInDatabase(event);

                // Cập nhật danh sách sự kiện
                setState(() {
                  // Cập nhật sự kiện trong danh sách events
                  List<Event>? eventList = events[event.date];
                  if (eventList != null) {
                    int index = eventList.indexWhere((e) => e.id == event.id);
                    if (index != -1) {
                      eventList[index] = event;
                    }
                  }
                  // Cập nhật sự kiện trong selectedEvents
                  selectedEvents.value = _getEventsForDay(selectedDay!);
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ham sua event
  void _updateEventInDatabase(Event event) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        DatabaseReference eventRef = _database
            .reference()
            .child('users')
            .child(user.uid)
            .child('events')
            .child(event.id);
        await eventRef.update({
          'title': event.title,
          'date': event.date.toIso8601String(),
        });
        print('Event updated in Firebase');
      }
    } catch (e) {
      print('Error updating event: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomNavigationPage(),
              ),
            );
          },
          icon: const Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 80,
      ),
      floatingActionButton: SizedBox(
        width: 120,
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Color.fromARGB(255, 255, 243, 247),
                  scrollable: true,
                  title: const Text(
                    "Add Reminder",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  content: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _eventController,
                      decoration: const InputDecoration(
                        hintText: 'Enter reminder name',
                      ),
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_eventController.text.isEmpty) return;
                        if (selectedDay != null) {
                          final event = Event(
                              Uuid().v4(), _eventController.text, selectedDay!);
                          events.putIfAbsent(selectedDay!, () => []).add(event);
                          _eventController.clear();
                          selectedEvents.value = _getEventsForDay(selectedDay!);
                          _saveEventToDatabase(event);
                          Navigator.of(context).pop();
                          showNotification(_eventController.text);
                          showEventNotification(_eventController);
                        }
                      },
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                );
              },
            );
          },
          child: GestureDetector(
            onTapDown: (_) => setState(() {
              EdgeInsets.only(bottom: 0.0);
            }),
            onTapUp: (_) => setState(() {
              EdgeInsets.only(bottom: 6.0);
            }),
            child: AnimatedContainer(
              padding: EdgeInsets.only(bottom: 6.0),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              duration: Duration(milliseconds: 100),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Add Remind",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
      body: content(),
    );
  }

  Widget content() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: TableCalendar(
              locale: "en_US",
              rowHeight: 43,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Colors.blueGrey,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Colors.blueGrey,
                ),
              ),
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(
                  color: Colors.blueGrey,
                ),
                weekendTextStyle: TextStyle(
                  color: Colors.redAccent,
                ),
                outsideDaysVisible: false,
                markersMaxCount: 1,
                markerDecoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                markersAlignment: Alignment.bottomCenter,
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                ),
                weekendStyle: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) => isSameDay(day, selectedDay),
              focusedDay: today,
              firstDay: DateTime.utc(2023, 1, 14),
              lastDay: DateTime.utc(2040, 3, 14),
              onPageChanged: (focusedDay) {
                today = focusedDay;
              },
              onDaySelected: _onDaySelected,
              eventLoader: _getEventsForDay,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: selectedEvents,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return const Center(
                    child: Text(
                      "Không có sự kiện nào",
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle_notifications_sharp,
                            color: Colors.orange,
                            size: 30,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "EVENT FOR DAY",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromARGB(255, 252, 221, 127),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              onLongPress: () =>
                                  _showConfirmDelete(context, value[index]),
                              onTap: () =>
                                  _showEditDialog(context, value[index]),
                              title: Text('${value[index].title}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  showNotification(eventsName) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 10,
          channelKey: "Remind_1",
          title: "Add Remind",
          body: "Add thanh cong $eventsName"),
    );
  }

  showEventNotification(eventsName) {
    DateTime _selectedDate = DateTime(2024,06,12,13,20);
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 10,
          channelKey: "Remind_1",
          title: "Add Remind",
          body: "Add thanh cong $eventsName"),
      schedule: NotificationCalendar.fromDate(date: _selectedDate),
    );
  }
}
