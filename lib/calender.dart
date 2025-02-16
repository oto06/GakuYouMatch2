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
      appBar: AppBar(
        title: const Text('Calendar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown[700],
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Group')
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
                'name': group['name'],
                'eventType': group['eventType'],
                'eventDetails': group['eventDetails'],
              });
            }
          }

          return _buildCalendar();
        },
      ),
    );
  }

  Widget _buildCalendar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2050, 12, 31),
            focusedDay: _focusedDay,
            eventLoader: (day) {
              return _events[day] ?? [];
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.brown,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Colors.red),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
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
          ),
        ),
      ),
    );
  }

  void _showEventDetails(List<Map<String, dynamic>> events) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          title: const Text(
              'イベント詳細', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: events.map((event) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📍 場所: ${event['name'] ?? '不明'}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('🏅 種目: ${event['eventType'] ?? '不明'}'),
                        const SizedBox(height: 4),
                        Text('📝 内容: ${event['eventDetails'] ?? '不明'}'),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                  '閉じる', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }
}