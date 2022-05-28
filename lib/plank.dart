import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'helpers.dart';

class Plank extends StatefulWidget {
  const Plank({Key? key}) : super(key: key);

  @override
  State<Plank> createState() => _PlankState();
}

class _PlankState extends State<Plank> {
  late int _secondsRemaining =
      (ModalRoute.of(context)!.settings.arguments as SecondsArguments).seconds;

  late final int _secondsSelected =
      (ModalRoute.of(context)!.settings.arguments as SecondsArguments).seconds;

  int _countdown = 2;
  Timer? _timer;

  bool _started = false;

  String _textToShow = 'Ready';

  final List<String> _list = [
    'Plank!',
    'Set',
    'Ready',
  ];

  startTimer() {
    _textToShow = _secondsRemaining.toString();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer innerTimer) {
        if (_secondsRemaining == 0) {
          endTimer();
        } else {
          setState(() => _secondsRemaining--);
          _textToShow = _secondsRemaining.toString();
        }
      },
    );
  }

  endTimer() {
    _timer?.cancel();

    Navigator.of(context).pushReplacementNamed(
      '/finishline',
      arguments: FinishArguments(
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
        _secondsRemaining == 0,
        _secondsRemaining,
        _secondsSelected,
      ),
    );
  }

  startCountdown() {
    _textToShow = _list[_countdown];

    Timer.periodic(
      const Duration(seconds: 1),
      (Timer innerTimer) => setState(
        () {
          if (_countdown == 0) {
            innerTimer.cancel();
            startTimer();
          } else {
            _countdown--;
            _textToShow = _list[_countdown];
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) {
      startCountdown();
      _started = true;
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 300.0,
            height: 300.0,
            child: TextButton(
              onPressed: endTimer,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: _secondsRemaining / _secondsSelected,
                    strokeWidth: 10,
                    backgroundColor: Colors.white,
                  ),
                  Center(
                    child: Text(
                      _textToShow,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 80,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
