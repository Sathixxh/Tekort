import 'package:flutter/material.dart';
import 'package:tekort/core/core/utils/styles.dart';

class PrimaryContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? radius;
  final EdgeInsets? padding;
  const PrimaryContainer(
      {required this.child, this.height, this.padding, this.radius,super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? EdgeInsets.all(16),
      decoration: BoxDecoration(
  
            
          borderRadius: BorderRadius.circular(10)),
      child: child,
    );
  }
}
