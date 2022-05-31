import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:daily_plank/helpers.dart' show FinishArguments;

/// Initialize sqflite for test.
void sqfliteTestInit() {
  // Initialize ffi implementation
  sqfliteFfiInit();
  // Set global factory
  databaseFactory = databaseFactoryFfi;
}

void main() {
  // TestWidgetsFlutterBinding.ensureInitialized();

  // sqfliteFfiInit();

  sqfliteTestInit();

  test('db_test', () async {
    final database = await openDatabase(inMemoryDatabasePath);

    database.execute(
      """
        CREATE TABLE progress(
          id INTEGER PRIMARY KEY,
          date TEXT,
          didFinish NUMERIC,
          secondsElapsed INTEGER,
          secondsSelected INTEGER
        )
      """,
    );

    final insert1 = FinishArguments(
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
      Random().nextDouble() <= 0.5,
      Random().nextInt(200) + 100,
      Random().nextInt(200),
    );

    final insert2 = FinishArguments(
      DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1))),
      Random().nextDouble() <= 0.5,
      Random().nextInt(200) + 100,
      Random().nextInt(200),
    );

    database.insert(
      'progress',
      insert1.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    database.insert(
      'progress',
      insert2.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    List<Map<String, dynamic>> results = await database.query('progress');

    final resultsList = List.generate(
      results.length,
      (index) => FinishArguments(
        results[index]['date'],
        results[index]['didFinish'] == "TRUE",
        results[index]['secondsElapsed'],
        results[index]['secondsSelected'],
      ),
    );

    expect(
      resultsList[0] == insert1 && resultsList[1] == insert2,
      true,
    );

    await database.close();
  });
}
