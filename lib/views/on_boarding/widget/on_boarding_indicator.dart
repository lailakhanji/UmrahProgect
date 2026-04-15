import 'package:flutter/material.dart';

class OnBoardingIndicator extends StatelessWidget {
    final ValueNotifier<int> currentIndex;
  const OnBoardingIndicator({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentIndex,
      builder: (context, current, child) {
        return Row(textDirection: TextDirection.rtl,
            spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index){
          return Container(
        height: 6,
        width: 37,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
        color: Theme.of(context).colorScheme.primary.withValues(
          alpha:(current==index)?1:0.20
        )),
          );
        })
        );
      }
    );
  }
}
