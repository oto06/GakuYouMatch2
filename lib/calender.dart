import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<Map<String, dynamic>>> _events;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _events = {}; // イベントデータを格納
    _focusedDay = DateTime.now(); // 初期値として現在の日付を設定
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カレンダー')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Group') // 'Group'コレクションを監視
            .orderBy('eventDate')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildCalendar();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildCalendar();
          }

          final groups = snapshot.data!.docs;

          _events.clear();
          for (var group in groups) {
            final eventDate = group['eventDate']?.toDate();
            if (eventDate != null) {
              DateTime dateKey =
              DateTime.utc(eventDate.year, eventDate.month, eventDate.day);
              if (_events[dateKey] == null) {
                _events[dateKey] = [];
              }
              _events[dateKey]?.add({
                'name': group['name'], // 場所
                'eventType': group['eventType'], // 種目
                'eventDetails': group['eventDetails'], // 内容
              });
            }
          }

          return _buildCalendar();
        },
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2050, 12, 31),
      focusedDay: _focusedDay,
      eventLoader: (day) {
        return _events[day] ?? [];
      },
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        weekendTextStyle: TextStyle(color: Colors.red),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
      ),
      selectedDayPredicate: (day) {
        return isSameDay(_focusedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });

        final selectedEvents = _events[selectedDay] ?? [];
        if (selectedEvents.isNotEmpty) {
          _showEventDetails(selectedEvents);
        }
      },
    );
  }

  void _showEventDetails(List<Map<String, dynamic>> events) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('イベント詳細'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: events.map((event) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('場所: ${event['name'] ?? '不明'}'),
                    Text('種目: ${event['eventType'] ?? '不明'}'),
                    Text('内容: ${event['eventDetails'] ?? '不明'}'),
                  ],
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }
} //yayaya
