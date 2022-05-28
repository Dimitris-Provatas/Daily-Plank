class SecondsArguments {
  SecondsArguments(this.seconds);

  final int seconds;
}

class FinishArguments {
  FinishArguments(
    this.date,
    this.didFinish,
    this.secondsElapsed,
    this.secondsSelected,
  );

  final String date;
  final bool didFinish;
  final int secondsSelected;
  final int secondsElapsed;

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'didFinish': didFinish ? "TRUE" : "FALSE",
      'secondsSelected': secondsSelected,
      'secondsElapsed': secondsElapsed,
    };
  }

  @override
  String toString() {
    return 'FinishArguments{date: $date, didFinish: $didFinish, secondsSelected: $secondsSelected, secondsElapsed: $secondsElapsed}';
  }
}

const String dbName = 'plank_db.db';
