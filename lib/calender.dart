import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {}; // 日付ごとのイベント

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('カレンダー')),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2050, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          SizedBox(height: 20),
          _buildEventList(), // イベントのリスト表示
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEventDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  // イベント追加用のダイアログ
  void _addEventDialog() {
    TextEditingController eventController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('イベントを追加'),
        content: TextField(
          controller: eventController,
          decoration: InputDecoration(hintText: 'イベントを入力'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              if (eventController.text.isEmpty) return;
              setState(() {
                if (_events[_selectedDay] == null) {
                  _events[_selectedDay] = [];
                }
                _events[_selectedDay]!.add(eventController.text);
              });
              Navigator.of(context).pop();
            },
            child: Text('追加'),
          ),
        ],
      ),
    );
  }

  // イベントリストの表示
  Widget _buildEventList() {
    List<String> selectedDayEvents = _events[_selectedDay] ?? [];

    return Expanded(
      child: ListView.builder(
        itemCount: selectedDayEvents.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(selectedDayEvents[index]),
          );
        },
      ),
    );
  }
}
