import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qlmoney/data/event.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'bottom_navigation_bar.dart';

class RemindPage extends StatefulWidget {
  const RemindPage({Key? key}) : super(key: key);

  @override
  State<RemindPage> createState() => _RemindPageState();
}

class _RemindPageState extends State<RemindPage> {
  DateTime today = DateTime.now();
  DateTime? selectedDay;
  TimeOfDay selectedTime = TimeOfDay(hour: 9, minute: 0);
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
    getRemindersFromChatbot();
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
          Map<DateTime, List<Event>> eventsMap = {};
          eventsData.forEach((key, value) {
            try {
              String eventId = key;
              String title = value['title'];
              DateTime date = DateTime.parse(value['date']);
              Event event = Event(eventId, title, date);
              eventsMap.update(date, (list) => [...list, event],
                  ifAbsent: () => [event]);
            } catch (e) {
              print('Error parsing event: $e');
            }
          });

          setState(() {
            events = eventsMap;
            selectedEvents.value = _getEventsForDay(selectedDay!);
          });
        }
      } catch (e) {
        print('Error getting events: $e');
      }
    }
  }

  void getRemindersFromChatbot() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _database
          .ref('users/${user.uid}/reminders')
          .orderByChild('created_at')
          .once();

      final data = snapshot.snapshot.value as Map?;
      if (data != null) {
        data.forEach((key, value) {
          try {
            final title = value['content'];
            final int day = value['day'];
            final int month = value['month'];
            final date = DateTime(DateTime.now().year, month, day);
            final event = Event(key, '[CHAT] $title', date);
            events.update(date, (list) => [...list, event],
                ifAbsent: () => [event]);
          } catch (e) {
            print('Lỗi xử lý chatbot reminder: $e');
          }
        });
        setState(() {
          selectedEvents.value = _getEventsForDay(selectedDay!);
        });
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
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () => _showEditDialog(context, value[index]),
                      onLongPress: () => _showConfirmDelete(context, value[index]),
                      title: Text(value[index].title),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _showConfirmDelete(context, value[index]),
                      ),
                      tileColor: Colors.amber[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: selectedTime,
          );
          if (pickedTime != null) selectedTime = pickedTime;

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: const Color.fromARGB(255, 255, 243, 247),
                scrollable: true,
                title: const Text("Add Reminder", style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
                content: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _eventController,
                    decoration: const InputDecoration(hintText: 'Enter reminder name'),
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_eventController.text.isEmpty) return;
                      if (selectedDay != null) {
                        final DateTime fullDateTime = DateTime(
                          selectedDay!.year,
                          selectedDay!.month,
                          selectedDay!.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );

                        final event = Event(Uuid().v4(), _eventController.text, fullDateTime);
                        events.putIfAbsent(selectedDay!, () => []).add(event);
                        _saveEventToDatabase(event);
                        _eventController.clear();
                        selectedEvents.value = _getEventsForDay(selectedDay!);
                        Navigator.of(context).pop();
                        scheduleEventNotification(event);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            },
          );
        },
        label: const Text("Add Remind"),
        icon: const Icon(Icons.add_alert_outlined),
      ),
      body: content(),
    );
  }

  void _saveEventToDatabase(Event event) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        String eventId = event.id;
        DatabaseReference eventRef = _database
            .ref()
            .child('users')
            .child(user.uid)
            .child('events')
            .child(eventId);
        await eventRef.set({
          'id': eventId,
          'title': event.title,
          'date': event.date.toIso8601String(),
        });
      }
    } catch (e) {
      print('Error saving event: $e');
    }
  }

  void _showEditDialog(BuildContext context, Event event) {
    TextEditingController _controller = TextEditingController(text: event.title);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Reminder"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: "Enter new title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  event.title = _controller.text;
                });
                _updateEventInDatabase(event);
                selectedEvents.value = _getEventsForDay(selectedDay!);
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _updateEventInDatabase(Event event) async {
    final user = _auth.currentUser;
    if (user != null) {
      DatabaseReference ref = _database
          .ref()
          .child('users')
          .child(user.uid)
          .child('events')
          .child(event.id);
      await ref.update({
        'title': event.title,
        'date': event.date.toIso8601String(),
      });
    }
  }

  void _showConfirmDelete(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Event"),
        content: Text("Are you sure you want to delete '${event.title}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              _deleteEventFromDatabase(event);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteEventFromDatabase(Event event) async {
    final user = _auth.currentUser;
    if (user != null) {
      if (event.title.startsWith('[CHAT]')) {
        // Reminder từ chatbot
        final reminderKey = event.id;
        await _database
            .ref('users/${user.uid}/reminders/$reminderKey')
            .remove();
      } else {
        // Reminder do người dùng thêm
        await _database
            .ref('users/${user.uid}/events/${event.id}')
            .remove();
      }

      setState(() {
        events[event.date]?.remove(event);
        selectedEvents.value = _getEventsForDay(selectedDay!);
      });
    }
  }



  void showNotification(String title) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: "Remind_1",
        title: "Reminder Created",
        body: "Successfully added: $title",
      ),
    );
  }

  void showEventNotification(String title) {
    DateTime notifyTime = DateTime.now().add(const Duration(seconds: 10));
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: "Remind_1",
        title: "Reminder",
        body: title,
      ),
      schedule: NotificationCalendar.fromDate(date: notifyTime),
    );
  }
}

void scheduleEventNotification(Event event) {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      channelKey: "Remind_1",
      title: "Reminder",
      body: event.title,
    ),
    schedule: NotificationCalendar(
      year: event.date.year,
      month: event.date.month,
      day: event.date.day,
      hour: event.date.hour,
      minute: event.date.minute,
      second: 0,
      repeats: false,
    ),
  );
}

