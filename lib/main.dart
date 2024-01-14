import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

typedef VoidCallback = void Function();

class SwapNotifier extends ChangeNotifier {
  SwapNotifier(this.swapp);
  ((Offset, double), (Offset, double), List<(Offset, double)>) swapp;
  Stream<((Offset, double), (Offset, double), List<(Offset, double)>)> fetch(
      List<(Offset, double)> centers,
      Duration duration,
      AnimationController controller) async* {
    for (int i = 0; i < centers.length - 1; i++) {
      for (int j = 0; j < centers.length - 1; j++) {
        if (centers[j].$2 > centers[j + 1].$2) {
          (Offset, double) temp = centers[j];
          centers[j] = centers[j + 1];
          centers[j + 1] = temp;
          var center1 = centers[j];
          var center2 = centers[j + 1];
          swapp = (center1, center2, centers);
          yield await Future.delayed(
              duration, () => (center1, center2, centers));
        }
      }
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  List<int> heights = List.generate(10, (index) => index + 1)..shuffle();
  List<double> heightFactors = [];
  bool swap = false;
  late Duration duration;
  List<(Offset, double)> centers = [];

  @override
  void initState() {
    duration = const Duration(milliseconds: 500);
    controller = AnimationController(vsync: this, duration: duration);
    animation = Tween<double>(begin: 1, end: 100).animate(controller);
    int maximum = 0;
    for (var i in heights) {
      maximum = math.max<int>(i, maximum);
    }
    for (var i in heights) {
      heightFactors.add(i / maximum);
    }

    controller.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubble Sort Visualizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SafeArea(
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                  animation: controller,
                  builder: (context, snapshot) {
                    return Row(children: [
                      Flexible(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints.loose(const Size.fromHeight(150)),
                          child: FractionallySizedBox(
                              heightFactor: 1,
                              widthFactor: 1,
                              child: LayoutBuilder(
                                  builder: (context, constraints) {
                                Size size = Size(constraints.maxWidth,
                                    constraints.maxHeight);
                                centers = List<(Offset, double)>.generate(
                                    10,
                                    (index) => (
                                          Offset(
                                              (size.width / 10) * index + (20),
                                              (size.height -
                                                      ((heightFactors[index]) *
                                                          size.height /
                                                          2)) /
                                                  2),
                                          heightFactors[index]
                                        ));
                                return ChangeNotifierProvider(
                                  create: (context) => SwapNotifier(
                                      (centers[0], centers[0], centers)),
                                  child: Consumer<SwapNotifier>(
                                      builder: (context, value, child) {
                                    return StreamBuilder<dynamic>(
                                        stream: value.fetch(
                                            centers, duration, controller),
                                        builder: (context, snapshot) {
                                          return RepaintBoundary(
                                            child: CustomPaint(
                                              isComplex: true,
                                              willChange: true,
                                              painter: ShapePainter(
                                                  swapp: snapshot.data,
                                                  value: animation.value,
                                                  heightFactorList:
                                                      heightFactors),
                                            ),
                                          );
                                        });
                                  }),
                                );
                              })),
                        ),
                      )
                    ]);
                  }),
              TextButton(onPressed: () {}, child: const Text("Switch"))
            ],
          ),
        ),
      ),
    );
  }
}

class ShapePainter2 extends CustomPainter {
  ShapePainter2({
    required this.value,
    required this.heightFactor,
  });
  final double value;

  final double heightFactor;

  List<(Offset, double)> centers = [];

  @override
  void paint(Canvas canvas, Size size) async {
    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 5
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    RRect fullrect1 = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset((size.width / 2),
              (size.height - (heightFactor * size.height / 2)) / 2),
          width: 10,
          height: heightFactor * size.height / 2),
      const Radius.circular(10),
    );
    canvas.drawRRect(fullrect1, paint);
  }

  @override
  bool shouldRepaint(covariant ShapePainter2 oldDelegate) => false;
}

class ShapePainter extends CustomPainter {
  ShapePainter({
    required this.value,
    this.swapp,
    required this.heightFactorList,
  });
  final double value;

  final List<double> heightFactorList;

  final ((Offset, double), (Offset, double), List<(Offset, double)>)? swapp;

  List<(Offset, double)> centers = [];

  @override
  void paint(Canvas canvas, Size size) async {
    // log("$value");
    List<(Offset, double)> centers = swapp == null
        ? List<(Offset, double)>.generate(
            10,
            (index) => (
                  Offset(
                      (size.width / 10) * index + (20),
                      (size.height -
                              ((heightFactorList[index]) * size.height / 2)) /
                          2),
                  heightFactorList[index]
                ))
        : swapp!.$3;
    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 5
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;
    for (var center in centers) {
      print(center);
      RRect fullrect1 = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center.$1, width: 10, height: center.$2 * size.height / 2),
        const Radius.circular(10),
      );
      canvas.drawRRect(fullrect1, paint);
    }
    print("\n");
    if (swapp != null) {
      swap(
          center1: swapp!.$1,
          center2: swapp!.$2,
          animationValue: value,
          canvas: canvas,
          size: size,
          paint: paint,
          centers: swapp!.$3);
    }
  }

  void swap(
      {required (Offset, double) center1,
      required (Offset, double) center2,
      required double animationValue,
      required Canvas canvas,
      required Size size,
      required Paint paint,
      required List<(Offset, double)> centers}) {
    paint.color = Colors.red;
    // callback.call();
    Offset interpolated1 = Offset(
        lerpDouble(center1.$1.dx, center2.$1.dx, animationValue / 100)!,
        center1.$1.dy);

    Offset interpolated2 = Offset(
        lerpDouble(center2.$1.dx, center1.$1.dx, animationValue / 100)!,
        center2.$1.dy);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: interpolated1,
                width: 10,
                height: center1.$2 * size.height / 2),
            const Radius.circular(10)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: interpolated2,
                width: 10,
                height: center2.$2 * size.height / 2),
            const Radius.circular(10)),
        paint);
  }

  @override
  bool shouldRepaint(covariant ShapePainter oldDelegate) => true;
}
