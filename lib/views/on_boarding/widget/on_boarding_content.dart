import 'package:flutter/material.dart';

class OnBoardingContent extends StatelessWidget {
  final String assetName;

  final String title;
  final String subTitle;

  const OnBoardingContent({
    super.key,
    required this.assetName,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          Image.asset(assetName),
          Spacer(),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 32),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 41),
            child: Text(
              textAlign: TextAlign.end,
              subTitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
