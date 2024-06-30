import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/reminder.dart';
import 'helpers/db_helper.dart';

void main() {
  runApp(ReminderApp());
}

class ReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReminderList(),
    );
  }
}

class ReminderList extends StatefulWidget {
  @override
  _ReminderListState createState() => _ReminderListState();
}

class _ReminderListState extends State<ReminderList> {
  late Future<List<Reminder>> _reminderList;

  @override
  void initState() {
    super.initState();
    _updateReminderList();
  }

  void _updateReminderList() {
    setState(() {
      _reminderList = DBHelper().getReminders();
    });
  }

  Future<void> _addReminder(String title, DateTime dateTime) async {
    Reminder reminder = Reminder(title: title, dateTime: dateTime);
    await DBHelper().insertReminder(reminder);
    _updateReminderList();
  }

  Future<void> _deleteReminder(int id) async {
    await DBHelper().deleteReminder(id);
    _updateReminderList();
  }

  Future<void> _showAddReminderDialog() async {
    TextEditingController _titleController = TextEditingController();
    DateTime? _selectedDateTime;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  _selectedDateTime = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (_selectedDateTime != null) {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      _selectedDateTime = DateTime(
                        _selectedDateTime!.year,
                        _selectedDateTime!.month,
                        _selectedDateTime!.day,
                        time.hour,
                        time.minute,
                      );
                    }
                  }
                },
                child: Text('Select Date and Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty && _selectedDateTime != null) {
                  _addReminder(_titleController.text, _selectedDateTime!);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddReminderDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<Reminder>>(
        future: _reminderList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Reminder reminder = snapshot.data![index];
              return ListTile(
                title: Text(reminder.title),
                subtitle: Text(DateFormat.yMMMd().add_jm().format(reminder.dateTime)),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteReminder(reminder.id!);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
