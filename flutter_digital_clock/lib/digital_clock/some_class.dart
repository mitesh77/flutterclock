import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as ui;
import 'package:flutter/painting.dart' as ui;
import 'package:intl/intl.dart' as date;

class CropPainter extends CustomPainter {
  final ui.Image backgroundImage;
  final TileObject tileObject;
  final BuildContext context;

  CropPainter(this.backgroundImage, this.context, {this.tileObject});

  @override
  bool shouldRepaint(CropPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var padding = 2 * tileObject.paddingValue;
    var w = ((tileObject.size.width - padding) * backgroundImage.width) / context.size.width;
    var h = ((tileObject.size.height - padding) * backgroundImage.height) / context.size.height;
    var source = Rect.fromLTWH((w * (tileObject.offset.dx + padding)) / (tileObject.size.width - padding),
        (h * (tileObject.offset.dy + padding)) / (tileObject.size.height - padding), w, h);
    canvas.scale(1.01, 1.01);
    canvas.drawImageRect(
        backgroundImage, source, Rect.fromLTWH(0, 0, (tileObject.size.width - padding), (tileObject.size.height - padding)), Paint());
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
  }
}

class ImageLoader {
  static ui.AssetBundle getAssetBundle() => (ui.rootBundle != null) ? ui.rootBundle : new ui.NetworkAssetBundle(new Uri.directory(Uri.base.origin));
  static Future<ui.Image> load(String url) async {
    ui.ImageStream stream = new ui.AssetImage(url, bundle: getAssetBundle()).resolve(ui.ImageConfiguration.empty);
    Completer<ui.Image> completer = new Completer<ui.Image>();
    ImageStreamListener listener;
    listener = new ImageStreamListener((ImageInfo frame, bool synchronousCall) {
      final ui.Image image = frame.image;
      completer.complete(image);
      stream.removeListener(listener);
    });
    stream.addListener(listener);
    return completer.future;
  }
}

class TileObject {
  AnimationController animationController;
  Size size;
  Offset offset;
  bool isDone;
  double paddingValue;
  bool only;
  bool onlyaAnimation;

  TileObject({
    this.animationController,
    this.size,
    this.offset,
    this.isDone = false,
    this.paddingValue = 0.0,
    this.only = false,
    this.onlyaAnimation = false,
  });
}

class SetTextOnImage {
  static Future<ui.Image> getImage(ui.Image forGroundImage) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImage(
      forGroundImage,
      Offset(0, 0),
      Paint(),
    );

    final timeStyle = TextStyle(
      color: Colors.white,
      fontSize: 120,
      fontWeight: FontWeight.bold,
    );
    final timeText = date.DateFormat("h:mm").format(DateTime.now());
    final timeSpan = TextSpan(
      text: timeText,
      style: timeStyle,
    );

    final timePainter = TextPainter(
      text: timeSpan,
      textDirection: TextDirection.ltr,
    );
    timePainter.layout(
      minWidth: 0,
      maxWidth: 500,
    );
    final offset = Offset(50, forGroundImage.height - 200.0);
    timePainter.paint(canvas, offset);

    final amStyle = TextStyle(
      color: Colors.white,
      fontSize: 40,
      fontWeight: FontWeight.bold,
    );
    final amSpan = TextSpan(
      text: date.DateFormat('a').format(DateTime.now()),
      style: amStyle,
    );

    final amPainter = TextPainter(
      text: amSpan,
      textDirection: TextDirection.ltr,
    );
    amPainter.layout(
      minWidth: 0,
      maxWidth: 600,
    );
    final amoffset = Offset(timeText.length > 4 ? 370 : 300, forGroundImage.height - 130.0);
    amPainter.paint(canvas, amoffset);

    final dataStyle = TextStyle(
      color: Colors.white,
      fontSize: 40,
      fontWeight: FontWeight.normal,
    );
    final dataSpan = TextSpan(
      text: date.DateFormat('EEEE, MMM d').format(DateTime.now()) + "  | ⛅ 23°C",
      style: dataStyle,
    );

    final dataPainter = TextPainter(
      text: dataSpan,
      textDirection: TextDirection.ltr,
    );
    dataPainter.layout(
      minWidth: 0,
      maxWidth: 500,
    );
    final dataoffset = Offset(60, forGroundImage.height - 80.0);
    dataPainter.paint(canvas, dataoffset);

    final picture = recorder.endRecording();
    return await picture.toImage(
      forGroundImage.width.toInt(),
      forGroundImage.height.toInt(),
    );
  }
}
