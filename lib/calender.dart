import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<String>> _events;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _events = {};  // 初期値として空のイベントマップを設定
    _focusedDay = DateTime.now(); // 初期値として現在の日付を設定
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Group') // 'Group'コレクションを監視
            .orderBy('eventDate')
            .snapshots(),
        builder: (context, snapshot) {
          // データが取得中の場合もカレンダーを表示
          if (snapshot.connectionState == ConnectionState.waiting) {
            // データがロード中でもカレンダーを表示
            return _buildCalendar();
          }

          // データが空でもカレンダーは表示
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildCalendar(); // 空データでもカレンダーを表示
          }

          final groups = snapshot.data!.docs;
          print('Firestoreから取得したイベント数: ${groups.length}');  // デバッグ用

          _events.clear();
          for (var group in groups) {
            final eventDate = group['eventDate']?.toDate();
            print('イベントの日付: $eventDate');  // 日付をデバッグ出力

            if (eventDate != null) {
              DateTime dateKey = DateTime.utc(eventDate.year, eventDate.month, eventDate.day);
              if (_events[dateKey] == null) {
                _events[dateKey] = [];
              }
              _events[dateKey]?.add(group['name']);
            }
          }

          return _buildCalendar(); // イベントがあっても、カレンダー表示部分は共通
        },
      ),
    );
  }

  // カレンダー表示を別のメソッドにまとめる
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2050, 12, 31),
      focusedDay: _focusedDay,
      eventLoader: (day) {
        // イベントデータが空でもカレンダーの日付に合わせてリストを返す
        return _events[day] ?? [];
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        weekendTextStyle: TextStyle(color: Colors.red),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
      ),
      selectedDayPredicate: (day) {
        return isSameDay(_focusedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
    );
  }
}


