import 'package:flutter/material.dart';
import 'package:palestine_filter/utils/color_filter.dart';

class CustomImageFilter extends StatelessWidget {
  final double brightness;
  final double saturation;
  final double hue;
  final Widget child;

  const CustomImageFilter({
    Key key,
    this.brightness = 0.0,
    this.saturation = 0.0,
    this.hue = 0.0,
    @required this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(ColorFilterGenerator.brightnessAdjustMatrix(
        value: brightness,
      )),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(ColorFilterGenerator.saturationAdjustMatrix(
          value: saturation,
        )),
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(ColorFilterGenerator.hueAdjustMatrix(
            value: hue,
          )),
          child: child,
        ),
      ),
    );
  }
}
