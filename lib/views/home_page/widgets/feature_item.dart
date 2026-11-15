import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FeatureItem extends StatelessWidget {
  final String icon;
  final String title;
  final String subTitle;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            child: Center(child: SvgPicture.asset(icon, width: 24, height: 20)),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xffEFFAF3),
            ),
          ),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          Text(subTitle, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
