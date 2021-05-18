import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CaptureWidget extends StatefulWidget {
  final Widget child;
  final Widget capture;

  const CaptureWidget({
    Key key,
    this.capture,
    this.child,
  }) : super(key: key);

  @override
  CaptureWidgetState createState() => CaptureWidgetState();
}

class CaptureWidgetState extends State<CaptureWidget> {
  final _boundaryKey = GlobalKey();

  Future<CaptureResult> captureImage() async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final boundary = _boundaryKey.currentContext.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ImageByteFormat.png);
    return CaptureResult(
      data.buffer.asUint8List(),
      image.width,
      image.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final height = constraints.maxHeight * 2;
        return Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            widget.child,
            Positioned(
              left: 0.0,
              right: 0.0,
              top: height,
              height: (height * 2),
              child: Center(
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: widget.capture,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CaptureResult {
  final Uint8List data;
  final int width;
  final int height;

  const CaptureResult(this.data, this.width, this.height);
}
