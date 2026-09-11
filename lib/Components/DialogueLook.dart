// ignore_for_file: use_super_parameters, file_names

import 'package:flutter/material.dart';

class ColoredCircle extends StatelessWidget {
  final Color color;
  final String text;
  final double height; // Optional parameter for circle height
  final double width; // Optional parameter for circle width

  const ColoredCircle({
    required this.color,
    required this.text,
    this.height = 30, // Default size
    this.width = 30, // Default size
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
