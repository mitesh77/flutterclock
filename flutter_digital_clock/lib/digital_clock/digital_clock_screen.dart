import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart' as ui;
import 'package:flutter/painting.dart' as ui;
import 'package:flutter_digital_clock/digital_clock/some_class.dart';

class DigitalClockScreen extends StatefulWidget {
  @override
  _DigitalClockScreenState createState() => _DigitalClockScreenState();
}

class _DigitalClockScreenState extends State<DigitalClockScreen> with TickerProviderStateMixin {
  
  AnimationController paddingAnimationController;
  final _random = new math.Random();
  var globalKey = new GlobalKey();
  List<TileObject> tileList = List<TileObject>();
  ui.Image backGroundImage;
  ui.Image forGroundImage;
  Timer timer;
  int next(int min, int max) => min + _random.nextInt(max - min);

  @override
  void initState() {
    paddingAnimationController = new AnimationController(
      vsync: this,
      duration: new Duration(milliseconds: 1200),
    );

    paddingAnimationController.addListener(() {
      for (var i = 0; i < tileList.length; i++) {
        var f = tileList[i];
        f.paddingValue = paddingAnimationController.value;
      }
    });
    setFirstTime();
    super.initState();

    timer = Timer.periodic(Duration(seconds: 18), (d) {
      if (mounted) callAnimation();
    });
  }

  void setFirstTime() async {
    await setImageImage();
    backGroundImage = forGroundImage;
    await setImageImage();
    if (mounted) {
      setState(() {
        getTileList();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    paddingAnimationController?.dispose();
    super.dispose();
  }

  void getTileList() async {
    tileList.clear();
    final colum = next(5, 9);
    final row = next(3, 7);
    try {
      final width = globalKey.currentContext.size.width / colum;
      final height = globalKey.currentContext.size.height / row;
      for (var i = 0; i < row; i++) {
        for (var j = 0; j < colum; j++) {
          var data = TileObject(
            animationController: new AnimationController(
              value: 180,
              vsync: this,
              duration: new Duration(milliseconds: 1000),
            ),
            size: Size(width, height),
            offset: Offset(width * j, height * i),
            only: i == 0 && j == 0 ? true : false,
          );
          tileList.add(data);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              key: globalKey,
              aspectRatio: 5 / 3,
              child: Stack(
                children: <Widget>[
                  for (var item in tileList)
                    Positioned(
                      top: item.offset.dy,
                      left: item.offset.dx,
                      width: item.size.width,
                      height: item.size.height,
                      child: AnimatedBuilder(
                        animation: paddingAnimationController,
                        builder: (BuildContext context, Widget child) {
                          return AnimatedBuilder(
                            animation: item.animationController,
                            builder: (BuildContext context, Widget child) {
                              return Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateX(
                                    degreesToRadians((AlwaysStoppedAnimation(Tween(begin: 0.0, end: 180)
                                                    .animate(CurvedAnimation(parent: item.animationController, curve: Curves.fastOutSlowIn)))
                                                .value)
                                            .value +
                                        0.0),
                                  ),
                                alignment: Alignment.center,
                                child: RotationTransition(
                                  turns: AlwaysStoppedAnimation(getRoValue(item: item) / 360),
                                  child: Transform(
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateY(degreesToRadians(getRoValue(item: item))),
                                    alignment: Alignment.center,
                                    child: CustomPaint(
                                      painter: CropPainter(
                                        item.onlyaAnimation ? forGroundImage : backGroundImage,
                                        globalKey.currentContext,
                                        tileObject: item,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void callAnimation() {
    paddingAnimationController.reset();
    paddingAnimationController.forward().then((f) async {
      tileList.forEach((f) async {
        await Future.delayed(Duration(milliseconds: next(240, 2400)));
        f.animationController.reset();
        f.animationController.forward().then((d) {
          f.isDone = true;
          reset();
        });
      });
    });
  }

  void reset() async {
    bool isAllDone = true;
    tileList.forEach((f) {
      if (!f.isDone) {
        isAllDone = false;
      }
    });
    if (isAllDone) {
      await Future.delayed(const Duration(milliseconds: 240));
      paddingAnimationController.reverse().then((f) async {
        await setImageImage();
        await Future.delayed(const Duration(milliseconds: 240));
        setState(() {
          getTileList();
        });
      });
    }
  }

  Future setImageImage() async {
    final imageIndex = next(1, 10);
    var newimage = await ImageLoader.load('assets/clock_image_$imageIndex.jpg');
    var imageWithText = await SetTextOnImage.getImage(newimage);
    backGroundImage = forGroundImage;
    forGroundImage = imageWithText;
  }

  double getRoValue({TileObject item}) {
    final newv =
        (AlwaysStoppedAnimation(Tween(begin: 0.0, end: 180).animate(CurvedAnimation(parent: item.animationController, curve: Curves.fastOutSlowIn)))
                .value)
            .value;
    if (newv != 180) {
      if (!item.onlyaAnimation && newv > 90) {
        item.onlyaAnimation = true;
      }
    }
    return newv > 90 ? 180 : 0;
  }

  double degreesToRadians(double number) {
    return number * math.pi / 180;
  }
}
