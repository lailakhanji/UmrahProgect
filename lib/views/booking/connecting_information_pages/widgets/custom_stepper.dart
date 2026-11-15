import 'package:flutter/material.dart';

class CustomStepper extends StatelessWidget {
  final int currentStep;

  const CustomStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const int totalSteps = 3;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {

          if (index.isEven) {
            final int step = (index ~/ 2) + 2;

            final bool isActive = step == currentStep;

            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? const Color(0xFF087443) : Colors.white,
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF087443)
                      : const Color(0xFFD9D9D9),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : const Color(0xFF777777),
                  ),
                ),
              ),
            );
          }


          return Expanded(
            child: Container(height: 2, color: const Color(0xFFD9D9D9)),
          );
        }),
      ),
    );
  }
}
