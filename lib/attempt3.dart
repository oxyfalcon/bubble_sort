import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent)),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<int> _numbers = [];
  final StreamController<List<int>> _streamController = StreamController();
  double _sampleSize = 300;
  bool isSorted = false;
  bool isSorting = false;
  int speed = 0;
  static int duration = 1500;

  Duration _getDuration() => Duration(microseconds: duration);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sampleSize = MediaQuery.of(context).size.width / 2;
    for (int i = 0; i < _sampleSize; ++i) {
      _numbers.add(Random().nextInt(500));
    }
  }

  Future<void> bubbleSort() async {
    for (int i = 0; i < _numbers.length; ++i) {
      for (int j = 0; j < _numbers.length - i - 1; ++j) {
        if (_numbers[j] > _numbers[j + 1]) {
          int temp = _numbers[j];
          _numbers[j] = _numbers[j + 1];
          _numbers[j + 1] = temp;
        }

        await Future.delayed(_getDuration(), () {});

        _streamController.add(_numbers);
      }
    }
  }

  void reset() {
    isSorted = false;
    _numbers = [];
    for (int i = 0; i < _sampleSize; ++i) {
      _numbers.add(Random().nextInt(500));
    }
    _streamController.add(_numbers);
  }

  Future<void> checkAndResetIfSorted() async {
    if (isSorted) {
      reset();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void changeSpeed() {
    setState(() {
      if (speed >= 3) {
        speed = 0;
        duration = 1500;
      } else {
        speed++;
        duration = duration ~/ 2;
      }
    });
  }

  void sort() async {
    setState(() {
      isSorting = true;
    });
    await checkAndResetIfSorted();
    await bubbleSort();
    setState(() {
      isSorting = false;
      isSorted = true;
    });
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Bubble Sort"),
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        ),
        body: SafeArea(
          child: StreamBuilder<List<int>>(
              initialData: _numbers,
              stream: _streamController.stream,
              builder: (context, snapshot) {
                List<int> numbers = snapshot.data!;
                int counter = 0;
                return Row(
                  children: numbers.map((int num) {
                    counter++;
                    return RepaintBoundary(
                      child: CustomPaint(
                        painter: BarPainter(
                            colorScheme: Theme.of(context).colorScheme,
                            index: counter,
                            value: num,
                            width: MediaQuery.of(context).size.width /
                                _sampleSize),
                      ),
                    );
                  }).toList(),
                );
              }),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                    onPressed: isSorting
                        ? null
                        : () {
                            reset();
                            setState(() {});
                          },
                    child: const Text("Reset")),
              )),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(onPressed: sort, child: const Text("Sort")),
              )),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                    onPressed: isSorting ? null : changeSpeed,
                    child: Text(
                      "${speed + 1}x",
                      style: const TextStyle(fontSize: 20),
                    )),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class BarPainter extends CustomPainter {
  final double width;
  final int value;
  final int index;
  final ColorScheme colorScheme;

  BarPainter(
      {required this.width,
      required this.value,
      required this.index,
      required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    if (value < 500 * .25) {
      paint.color = colorScheme.inversePrimary;
    } else if (value < 500 * .5) {
      paint.color = colorScheme.primaryContainer;
    } else if (value < 500 * .75) {
      paint.color = colorScheme.primary;
    } else {
      paint.color = colorScheme.onPrimaryContainer;
    }

    paint.strokeWidth = width;
    paint.strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(index * width, 0),
        Offset(index * width, value.ceilToDouble()), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
