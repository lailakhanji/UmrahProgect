import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umrahapp/constants/my_assets_url.dart';
import 'package:umrahapp/entities/on_boarding_content_data.dart';
import 'package:umrahapp/utils/helper_function.dart';
import 'package:umrahapp/views/authentication/auth_screen.dart';
import 'package:umrahapp/views/on_boarding/widget/on_boarding_content.dart';
import 'package:umrahapp/views/on_boarding/widget/on_boarding_indicator.dart';

import '../authentication/auth_bloc/auth_bloc.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _DefinitionInterfaceState();
}

class _DefinitionInterfaceState extends State<OnBoardingScreen> {
  late final ValueNotifier<int> currentIndex;
 late PageController _pageController;
  final List<OnBoardingContentData> onBoardingData=[
OnBoardingContentData(title: "رحلة عمرة متكاملة", subTitle:" تبدأ رحلتك الكاملة من هنا تخطيط, حجز و إدارة العمرة بسهولة  في مكان واحد", assetName: MyAssetsUrl.firstpageimage),
  OnBoardingContentData(title: "أداء العمرة خطوة بخطوة", subTitle:"تتبع رحلتك و اتبع مسار العمرة المرشد بخطوات و نصائح واضحة",assetName: MyAssetsUrl.firstpageimage),
  ];
  @override
  void initState() {
    currentIndex=ValueNotifier(0);
    _pageController =PageController(initialPage: 0);
    super.initState();
  }
  @override
  void dispose() {
    currentIndex.dispose();
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(alignment: Alignment.center,
        children:[ PageView.builder(reverse: true,
          controller: _pageController,
          onPageChanged: (index){
currentIndex.value=index;
          },
            itemCount: onBoardingData.length,
                itemBuilder: (context,index){
              return Column(
                children: [
                  Spacer(),
                  OnBoardingContent(assetName: onBoardingData[index].assetName, title: onBoardingData[index].title, subTitle: onBoardingData[index].subTitle),

                  Spacer()
                ],
              );
            }
        ),
          Positioned(top: 629,
              child: OnBoardingIndicator(currentIndex: currentIndex)),
          Positioned(bottom: 48,
            child: Row(
              children: [
                ElevatedButton(onPressed: (){
                  if(currentIndex.value==0){
            _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);}
                  else{
                    HelperFunction.navigateAndReplaceScreen(
                      context,
                      BlocProvider(
                        create: (context) => AuthBloc(),
                        child: AuthScreen(isForLogin: false),
                      ),
                    );
                  }
                }, child:Text( "التالي",style: Theme.of(context).textTheme.labelSmall,),
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary,
                      minimumSize: Size(93, 28),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)
                      )),
                ),
                SizedBox(width: 175,),
                MaterialButton(onPressed: (){ HelperFunction.navigateAndReplaceScreen(context,AuthScreen(isForLogin: false));},
                  child: Text("تخطي"),
                ),
              ],
            ),
          )
      ])
    );
  }
}
