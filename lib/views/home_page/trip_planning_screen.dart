import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:umrahapp/utils/helper_function.dart';
import 'package:umrahapp/views/home_page/packagesScreen.dart';
import 'package:umrahapp/views/trip/trip_selection_screen.dart';

import 'home_bloc/home_bloc.dart';

class TripPlanningScreen extends StatelessWidget {
  const TripPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 138,
          centerTitle: true,
          title: Column(
            children: [
              Text(
                'خطط لعمرتك',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 25,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'اختر كيف تريد التخطيط لرحلتك',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 30),
              SizedBox(
                width: 320,
                child: ListTile(
                  onTap: () {
                    HelperFunction.navigate(
                      context,
                      BlocProvider.value(
                        value: context.read<HomeBloc>()
                          ..add(GetHomeCategories()),
                        child: const Packagesscreen(),
                      ),
                    );
                  },
                  contentPadding: EdgeInsets.all(12),
                  tileColor: Color.fromRGBO(239, 250, 243, 0.75),
                  minTileHeight: 108,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(8),
                  ),
                  title: Text(
                    'باقات جاهزة',

                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                  subtitle: Text(
                    'اختر من بين أفضل باقات العمرة لدينا',
                    maxLines: 2, // ينزل لسطرين فقط كحد أقصى
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                  ),
                  leading: SvgPicture.asset('assets/icons/mdi_gift.svg'),
                ),
              ),
              SizedBox(height: 50),
              SizedBox(
                width: 320,
                child: ListTile(
                  onTap: () {
                    HelperFunction.navigate(
                      context,
                      const TripSelectionScreen(),
                    );
                  },
                  contentPadding: EdgeInsets.all(12),
                  tileColor: Color.fromRGBO(239, 250, 243, 0.75),
                  minTileHeight: 108,
                  title: Text(
                    'صمم باقتك',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                  subtitle: Text(
                    'قم بإنشاء باقتك الخاصة خطوة بخطوة',
                    maxLines: 2, // ينزل لسطرين فقط كحد أقصى
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                  ),
                  leading: SvgPicture.asset('assets/icons/mdi_puzzle.svg'),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
