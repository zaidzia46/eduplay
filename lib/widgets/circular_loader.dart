import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CircularLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 70,
        child: Lottie.asset('assets/animations/loader.json'),
      ),
    );
  }
}
