import 'package:flutter/material.dart';
import 'package:gakuyoumatch2/map%20search.dart';
import 'package:gakuyoumatch2/map_home.dart';
import 'package:gakuyoumatch2/profile.dart';
import 'package:table_calendar/table_calendar.dart';
import 'Chat.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {}; // 日付ごとのイベント

  int _selectedIndex = 3;


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
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color:Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.purpleAccent,
                shape: BoxShape.circle,
            ),
              markerDecoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600),
              weekendTextStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: Colors.pinkAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
        calendarBuilders: CalendarBuilders(
          // ここでイベントがある日を強調
          defaultBuilder: (context, day, focusedDay) {
            if (_events[day] != null && _events[day]!.isNotEmpty) {
              // イベントがある日なら背景色を付ける
              return Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blueAccent, // 背景色
                  shape: BoxShape.circle, // 円形にする
                ),
                child: Text(
                  '${day.day}',
                  style: TextStyle(color: Colors.white), // テキスト色
                ),
              );
            }
            // 通常の日付の表示
            return null;
          },
          // 選択された日のスタイルも変更できる
          selectedBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.green, // 選択された日付の背景色
                shape: BoxShape.circle,
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(color: Colors.white), // 選択された日のテキスト色
              ),
            );
          },
            ),
          ),
          SizedBox(height: 100),
          _buildEventList(), // イベントのリスト表示
        ],
      ),
      );

  }

  // イベント追加用のダイアログ
  void _addEventDialog() {
    TextEditingController eventController = TextEditingController();
    TimeOfDay? _selectedTime; // 時間を管理する変数

    // 時間選択関数
    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null && pickedTime != _selectedTime) {
        setState(() {
          _selectedTime = pickedTime;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('イベントを追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // イベント名の入力フィールド
            TextField(
              controller: eventController,
              decoration: InputDecoration(hintText: 'イベントを入力'),
            ),
            SizedBox(height: 20),

            // 時間選択用のボタン
            ElevatedButton(
              onPressed: () {
                _selectTime(context); // 時間を選択
              },
              child: Text(_selectedTime == null
                  ? '時間を選択'
                  : '選択された時間: ${_selectedTime!.format(context)}'),
            ),
          ],
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
              if (eventController.text.isEmpty || _selectedTime == null) return;
              setState(() {
                if (_events[_selectedDay] == null) {
                  _events[_selectedDay] = [];
                }
                // イベントと時間を追加
                _events[_selectedDay]!.add(
                    '${eventController.text} - ${_selectedTime!.format(context)}');
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
