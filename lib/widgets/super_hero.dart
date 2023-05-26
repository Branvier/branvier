import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Scaffold(body: TestWidget())));

class TestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: List.generate(
          15,
          (listIndex) => SizedBox(
            height: 150, // Set the width as per your requirements.
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (context, itemIndex) {
                return SuperHero(
                  builder: (context, flying) {
                    return SizedBox.square(
                      dimension: 300,
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(itemIndex.toString()),
                            Text(flying ? 'Im flying' : 'On ground'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ? work in progress
class SuperHero extends StatelessWidget {
  // Builder function that creates a widget based on the 'flying' state.
  final Widget Function(BuildContext context, bool flying) builder;

  /// The 'fly' animation duration.
  final Duration duration;
  final Curve curve;
  final Color barrierColor;

  const SuperHero({
    required this.builder,
    this.curve = Curves.ease,
    this.duration = const Duration(seconds: 1),
    this.barrierColor = Colors.black38,
  });

  @override
  Widget build(BuildContext context) {
    final tag = builder(context, false).hashCode.toString();

    return GestureDetector(
      onTap: () {
        Scrollable.ensureVisible(
          context,
          alignment: 0.5,
          duration: duration,
          curve: curve,
        );
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            transitionDuration: const Duration(seconds: 1),
            barrierDismissible: true,
            barrierColor: barrierColor,
            pageBuilder: (context, animation, secondaryAnimation) {
              return Center(
                child: Hero(
                  tag: tag,
                  createRectTween: (begin, end) {
                    return CurveRectTween(
                      begin: begin,
                      end: end,
                      arcEffect: 500,
                      curve: curve,
                    );
                  },
                  child: builder(context, true),
                ),
              );
            },
            transitionsBuilder: (context, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Hero(
        tag: tag,
        createRectTween: (begin, end) {
          return CurveRectTween(
            begin: begin,
            end: end,
            curve: curve,
          );
        },
        child: builder(context, false),
      ),
    );
  }
}

class CurveRectTween extends RectTween {
  final Curve curve;
  final double arcEffect;

  CurveRectTween({
    required Rect? begin,
    required Rect? end,
    required this.curve,
    this.arcEffect = 0.0,
  }) : super(begin: begin, end: end);

  @override
  Rect lerp(double t) {
    final easedT = curve.transform(t); // interpolation

    return super.lerp(easedT)!;

    // Calculate the arc offset
    // double directionX = (end!.center.dx - begin!.center.dx).sign;
    // double directionY = (end!.center.dy - begin!.center.dy).sign;

    // double offsetX = directionX * 0.5 * arcEffect * sin(easedT * pi);
    // double offsetY = directionY * 0.5 * arcEffect * sin(easedT * pi);

    // // Interpolate the rectangle's properties using the curved fraction,
    // // adjusted by the arc offset
    // return Rect.fromLTRB(
    //   lerpDouble(begin!.left, end!.left, easedT)! + offsetX,
    //   lerpDouble(begin!.top, end!.top, easedT)! + offsetY,
    //   lerpDouble(begin!.right, end!.right, easedT)! + offsetX,
    //   lerpDouble(begin!.bottom, end!.bottom, easedT)! + offsetY,
    // );
  }
}
