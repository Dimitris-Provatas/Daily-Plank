import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'helpers.dart' show FinishArguments, dbName;

class FinishLine extends StatefulWidget {
  const FinishLine({Key? key}) : super(key: key);

  @override
  State<FinishLine> createState() => _FinishLineState();
}

class _FinishLineState extends State<FinishLine> {
  late final FinishArguments finishArguments =
      ModalRoute.of(context)!.settings.arguments as FinishArguments;

  bool didStore = false;

  Future<void> storeResult() async {
    final database = await openDatabase(
      path.join(await getDatabasesPath(), dbName),
    );

    database.insert(
      'progress',
      finishArguments.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!didStore) {
      didStore = true;
      storeResult();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FractionallySizedBox(
          widthFactor: 0.9,
          child: Text(
            textAlign: TextAlign.center,
            finishArguments.didFinish
                ? 'You did it! Go for more seconds next time!'
                : 'You didn\'t finish the plank! You need to train harder!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 48),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue,
            shadowColor: Colors.grey[700],
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Back to the Start',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
