import 'package:flutter/material.dart';

class CircularIcon extends StatelessWidget {
  final void Function() onTap;
  final IconData iconData;
  final Color iconColor;
  final String tooltip;
  final Color backgroundColor;

  const CircularIcon({
    Key key,
    this.onTap,
    this.iconData,
    this.iconColor = Colors.white,
    this.tooltip,
    this.backgroundColor,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: backgroundColor,
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(iconData, color: iconColor),
        onPressed: onTap,
      ),
    );
  }
}
