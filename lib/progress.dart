import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'helpers.dart' show FinishArguments, dbName;

class Progress extends StatefulWidget {
  const Progress({Key? key}) : super(key: key);

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  Future<List<FinishArguments>> getProgress({
    String? dateString,
  }) async {
    final database = await openDatabase(
      path.join(await getDatabasesPath(), dbName),
    );

    List<Map<String, dynamic>> progressMap;

    if (dateString == null) {
      progressMap = await database.query(
        'progress',
        orderBy: 'id DESC',
        limit: 7,
      );
    } else {
      progressMap = await database.query(
        'progress',
        where: 'date = ?',
        whereArgs: [
          dateString,
        ],
        orderBy: 'id DESC',
        limit: 7,
      );
    }

    final toReturn = List.generate(
      progressMap.length,
      (index) => FinishArguments(
        progressMap[index]['date'],
        progressMap[index]['didFinish'] == 1,
        progressMap[index]['secondsElapsed'],
        progressMap[index]['secondsSelected'],
      ),
    );

    return toReturn;
  }

  @override
  void initState() {
    getProgress();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    myFutureBuilder(
        BuildContext context, AsyncSnapshot<List<FinishArguments>> snapshot) {
      final Orientation orientation = MediaQuery.of(context).orientation;

      if (!snapshot.hasData) {
        return const CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.blue,
        );
      }

      final List<FinishArguments> progressList = snapshot.data!;

      List<FinishArguments> getSeries() {
        final List<FinishArguments> toReturn = [];

        for (int i = 0; i < progressList.length; i++) {
          toReturn.add(progressList[i]);
        }

        return toReturn;
      }

      return SfCartesianChart(
        primaryXAxis: DateTimeAxis(
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          dateFormat: DateFormat.MMMd(),
          intervalType: DateTimeIntervalType.days,
          interval: 1,
          majorGridLines: const MajorGridLines(
            width: 0,
          ),
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: 315,
          interval: 30,
          labelFormat: '{value}s',
          edgeLabelPlacement: EdgeLabelPlacement.shift,
        ),
        series: [
          LineSeries<FinishArguments, DateTime>(
            animationDuration: 500,
            dataSource: getSeries(),
            xValueMapper: (FinishArguments progress, _) =>
                DateTime.parse(progress.date),
            yValueMapper: (FinishArguments progress, _) =>
                progress.secondsElapsed,
            color: Colors.blue,
            markerSettings: const MarkerSettings(
              isVisible: true,
            ),
          ),
          LineSeries<FinishArguments, DateTime>(
            animationDuration: 500,
            dataSource: getSeries(),
            xValueMapper: (FinishArguments progress, _) =>
                DateTime.parse(progress.date),
            yValueMapper: (FinishArguments progress, _) =>
                progress.secondsSelected,
            color: Colors.red,
            markerSettings: const MarkerSettings(
              isVisible: true,
            ),
          ),
        ],
        annotations: <CartesianChartAnnotation>[
          CartesianChartAnnotation(
            widget: SizedBox(
              child: Column(
                children: [
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.circle,
                        color: Colors.blue,
                        size: 16 / MediaQuery.of(context).textScaleFactor,
                      ),
                      const Text(
                        ' Elapsed',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.circle,
                        color: Colors.red,
                        size: 16 / MediaQuery.of(context).textScaleFactor,
                      ),
                      const Text(
                        ' Target',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            coordinateUnit: CoordinateUnit.percentage,
            x: '85%',
            y: '10%',
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder(
            future: getProgress(),
            builder: myFutureBuilder,
          ),
          const SizedBox(height: 50),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              shadowColor: Colors.grey[700],
            ),
            onPressed: () => Navigator.of(context).pushNamed(
              '/',
            ),
            child: const Text(
              'Back to Home',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
