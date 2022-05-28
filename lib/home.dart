import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'helpers.dart' show SecondsArguments, dbName;
import 'notification_manager.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _hasPlankedToday = false;

  int _parsedNumber = 45;

  int _hours = 18;
  int _minutes = 30;

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();

    getParsedNumber();
    getTime();
    getIfPlankedToday();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  Future<void> getIfPlankedToday() async {
    final database = await openDatabase(
      path.join(await getDatabasesPath(), dbName),
    );

    final result = await database.query(
      'progress',
      where: 'date = ?',
      whereArgs: [
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
      ],
    );

    setState(() {
      _hasPlankedToday = result.isNotEmpty;
    });
  }

  void changeNumberOfSeconds(double newNumber) {
    setState(() {
      _parsedNumber = newNumber.toInt();

      storeValue();
    });
  }

  Future<void> getTime() async {
    _hours =
        (await SharedPreferences.getInstance()).getInt('notification_hours') ??
            18;
    _minutes = (await SharedPreferences.getInstance())
            .getInt('notification_minutes') ??
        30;
  }

  Future<void> storeValue() async {
    (await SharedPreferences.getInstance()).setInt('seconds', _parsedNumber);
  }

  Future<void> getParsedNumber() async {
    final int parsedNumber =
        (await SharedPreferences.getInstance()).getInt('seconds') ?? 45;

    setState(() {
      _parsedNumber = parsedNumber;
    });
  }

  setNewTime() async {
    TimeOfDay? selectedTime = await showTimePicker(
      initialTime: TimeOfDay(
        hour: _hours,
        minute: _minutes,
      ),
      context: context,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      _hours = selectedTime.hour;
      _minutes = selectedTime.minute;
    });

    (await SharedPreferences.getInstance())
        .setInt('notification_hours', selectedTime.hour);
    (await SharedPreferences.getInstance())
        .setInt('notification_minutes', selectedTime.minute);

    NotificationManager.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Title(
                      color: Colors.white,
                      child: const Text(
                        'Daily Plank',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Time Selector
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: setNewTime,
                    child: Text('Daily at: $_hours:$_minutes'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Start button
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: 300.0,
                      height: 300.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: TextButton(
                        onPressed: _hasPlankedToday
                            ? null
                            : () => Navigator.pushNamed(
                                  context,
                                  '/plank',
                                  arguments: SecondsArguments(_parsedNumber),
                                ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shadowColor: Colors.grey[700],
                          fixedSize: const Size(200, 200),
                          shape: const CircleBorder(),
                        ),
                        child: Text(
                          _hasPlankedToday
                              ? 'Come back Tomorrow'
                              : 'Start Planking',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            // Seconds to plank
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    "Seconds to Plank: $_parsedNumber",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                //   Flexible(
                //     child: TextField(
                //       controller: _controller,
                //       inputFormatters: [
                //         FilteringTextInputFormatter.digitsOnly,
                //       ],
                //       onChanged: (value) =>
                //           changeNumberOfSeconds(double.parse(value)),
                //       keyboardType: TextInputType.number,
                //     ),
                //   ),
              ],
            ),
            // Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    child: Slider(
                      value: _parsedNumber.toDouble(),
                      onChanged: changeNumberOfSeconds,
                      min: 1,
                      max: 300,
                      divisions: 300,
                      label:
                          '$_parsedNumber ${_parsedNumber > 1 ? 'seconds' : 'second'}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Progress Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shadowColor: Colors.grey[700],
                  ),
                  onPressed: () => Navigator.of(context).pushNamed(
                    '/progress',
                  ),
                  child: const Text(
                    'View Progress',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
