import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'helpers.dart' show dbName;
import 'notification_manager.dart';

import 'finishline.dart';
import 'home.dart';
import 'plank.dart';
import 'progress.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationManager.init();

  initDB();

  runApp(const MyApp());
}

initDB() async {
  openDatabase(
    path.join(await getDatabasesPath(), dbName),
    onCreate: (db, version) {
      // https://www.sqlite.org/datatype3.html
      return db.execute(
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
    },
    version: 1,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
      ),
      routes: <String, WidgetBuilder>{
        '/plank': (BuildContext context) => const Plank(),
        '/finishline': (BuildContext context) => const FinishLine(),
        '/progress': (BuildContext context) => const Progress(),
      },
      // onGenerateRoute: (settings) {
      //   dynamic routeTo = const Home();

      //   switch (settings.name) {
      //     case '/':
      //       routeTo = const Home();
      //       break;
      //     case '/plank':
      //       routeTo = const Plank();
      //       break;
      //     case '/finishline':
      //       routeTo = const FinishLine();
      //       break;
      //     case '/progress':
      //       routeTo = const Progress();
      //       break;
      //     default:
      //       routeTo = const Home();
      //       break;
      //   }

      //   return PageRouteBuilder(
      //     settings: settings,
      //     pageBuilder: (_, __, ___) => routeTo,
      //     transitionsBuilder: (_, a, __, c) => FadeTransition(
      //       opacity: a,
      //       child: c,
      //     ),
      //   );
      // },
      home: const Home(),
    );
  }
}
