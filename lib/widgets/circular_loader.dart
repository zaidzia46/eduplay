import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../theme/app_colors.dart';

class CircularLoader extends StatelessWidget {
  final Color? color;
  const CircularLoader({super.key, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 70,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
          child: Lottie.asset('assets/animations/loader.json'),
        ),
      ),
    );
  }
}
