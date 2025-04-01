import 'package:flutter/material.dart';

class AnimatedCircle extends StatelessWidget {
  final bool isFilled;

  const AnimatedCircle({Key? key, required this.isFilled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 10,
      backgroundColor: isFilled ? Colors.green : Colors.red,
    );
  }
}
