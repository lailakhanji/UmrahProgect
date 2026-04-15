
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/shared_preferances_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 70,),
          Row(spacing: 20,
            children: [
              SizedBox(width: 5,),
              SvgPicture.asset('assets/icons/iconoir_profile-circle (1).svg'),
             SvgPicture.asset('assets/icons/Vector.svg'),
              SizedBox(width: 100,),
              Text('! ${SharedPreferancesService.name}, مرحبا بك    ',style: Theme.of(context).textTheme.titleMedium,),

            ],
          ),
          SizedBox(height: 20,),
          Text('ابدأ التخطيط لرحلتك الان',style: Theme.of(context).textTheme.titleLarge,)
        ],
      ),
    );
  }
}
