import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:umrahapp/constants/my_assets_url.dart';
import 'package:umrahapp/utils/helper_function.dart';

import 'package:umrahapp/views/home_page/home_bloc/home_bloc.dart';
import 'package:umrahapp/views/home_page/package_detail_screen.dart';
import 'package:umrahapp/views/home_page/packagesScreen.dart';

import 'package:umrahapp/views/home_page/widgets/GuideProgressService.dart';
import 'package:umrahapp/views/home_page/widgets/al_dalil_card.dart';
import 'package:umrahapp/views/home_page/widgets/widget_card.dart';

import '../notifications/data/notification_api_service.dart';
import '../notifications/notification_bloc/notification_bloc.dart';
import '../notifications/notification_screen.dart';

import '../profile/profile_screen.dart';
import '../smart_assistance/smart_assistant_screen.dart';

class HomeScreen extends StatefulWidget {
  final String name;
  final Function(int)? onNavigate;

  const HomeScreen({super.key, required this.onNavigate, required this.name});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // =========================================================
  // GUIDE
  // =========================================================

  Set<String> completedGuideIds = {};

  int totalGuideSteps = 0;

  bool guideLoading = true;

  // =========================================================
  // BELL ANIMATION
  // =========================================================

  late AnimationController _bellController;

  late Animation<double> _bellAnimation;

  @override
  void initState() {
    super.initState();

    _loadGuideProgress();

    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _bellAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0, end: -0.15),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: -0.15, end: 0.15),
            weight: 2,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.15, end: -0.1),
            weight: 2,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: -0.1, end: 0),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(parent: _bellController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _bellController.dispose();

    super.dispose();
  }

  // =========================================================
  // GUIDE PROGRESS
  // =========================================================

  Future<void> _loadGuideProgress() async {
    try {
      final completedIds = await GuideProgressService.getCompletedGuideIds();

      final totalSteps = await GuideProgressService.getTotalSteps();

      if (!mounted) return;

      setState(() {
        completedGuideIds = completedIds;

        totalGuideSteps = totalSteps;

        guideLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        guideLoading = false;
      });
    }
  }

  Future<void> refreshGuideProgress() async {
    await _loadGuideProgress();
  }

  // =========================================================
  // BELL SHAKE
  // =========================================================

  void _startBellAnimation() {
    if (!_bellController.isAnimating) {
      _bellController.repeat(reverse: true);
    }
  }

  void _stopBellAnimation() {
    _bellController.stop();

    _bellController.reset();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // =====================================================
        // HOME BLOC
        // =====================================================
        BlocProvider<HomeBloc>(
          lazy: false,
          create: (context) => HomeBloc()..add(GetHomeCategories()),
        ),

        // =====================================================
        // NOTIFICATION BLOC
        // =====================================================
        BlocProvider<NotificationBloc>(
          lazy: false,
          create: (context) => NotificationBloc(NotificationApiService())
            ..add(GetNotificationsEvent())
            ..add(StartNotificationPollingEvent()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            resizeToAvoidBottomInset: false,

            body: SafeArea(
              child: Column(
                children: [
                  // =================================================
                  // HEADER
                  // =================================================
                  Padding(
                    padding: const EdgeInsets.only(top: 3, left: 16, right: 16),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          const Spacer(),

                          // =========================================
                          // PROFILE
                          // =========================================
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              );
                            },
                            icon: SvgPicture.asset(
                              'assets/icons/si_user-alt-6-line.svg',
                            ),
                          ),

                          const Spacer(),

                          // =========================================
                          // NOTIFICATIONS
                          // =========================================
                          BlocConsumer<NotificationBloc, NotificationState>(
                            listener: (context, state) {
                              if (state is SuccessNotificationState) {
                                if (state.isBellRinging) {
                                  _startBellAnimation();
                                } else {
                                  _stopBellAnimation();
                                }
                              }
                            },
                            builder: (context, state) {
                              int notificationCount = 0;

                              if (state is SuccessNotificationState) {
                                notificationCount = state.unreadCount;
                              }

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  AnimatedBuilder(
                                    animation: _bellAnimation,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle: _bellAnimation.value,
                                        alignment: Alignment.topCenter,
                                        child: child,
                                      );
                                    },
                                    child: IconButton(
                                      onPressed: () async {
                                        final notificationBloc = context
                                            .read<NotificationBloc>();

                                        notificationBloc.add(
                                          ClearNotificationBadgeEvent(),
                                        );

                                        _stopBellAnimation();

                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BlocProvider.value(
                                              value: notificationBloc,
                                              child: const NotificationScreen(),
                                            ),
                                          ),
                                        );

                                        if (!mounted) return;

                                        notificationBloc.add(
                                          GetNotificationsEvent(),
                                        );
                                      },
                                      icon: SvgPicture.asset(
                                        'assets/icons/iconamoon_notification-light.svg',
                                      ),
                                    ),
                                  ),

                                  // =================================
                                  // RED BADGE
                                  // =================================
                                  if (notificationCount > 0)
                                    Positioned(
                                      right: 4,
                                      top: 2,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          notificationCount > 9
                                              ? '9+'
                                              : '$notificationCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),

                          const Spacer(flex: 20),

                          // =========================================
                          // USER NAME
                          // =========================================
                          Text('مرحباً ، ${widget.name}'),

                          const Spacer(),
                        ],
                      ),
                    ),
                  ),

                  // =================================================
                  // BODY
                  // =================================================
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        // ===========================================
                        // UPDATE PACKAGES
                        // ===========================================

                        context.read<HomeBloc>().add(GetHomeCategories());

                        // ===========================================
                        // UPDATE NOTIFICATIONS
                        // ===========================================

                        context.read<NotificationBloc>().add(
                          CheckNewNotificationsEvent(),
                        );

                        // ===========================================
                        // UPDATE GUIDE
                        // ===========================================

                        await refreshGuideProgress();

                        // ===========================================
                        // WAIT FOR HOME
                        // ===========================================

                        await context.read<HomeBloc>().stream.firstWhere(
                          (state) =>
                              state is SuccessCategoryState ||
                              state is FailedCategoryState,
                        );
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),

                            // =======================================
                            // HOME IMAGE
                            // =======================================
                            SizedBox(
                              height: 210,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                      child: Image.asset(
                                        MyAssetsUrl.homePageImage,
                                        width: double.infinity,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  // =================================
                                  // GREEN CARD
                                  // =================================
                                  Positioned(
                                    left: 16,
                                    right: 16,
                                    bottom: 10,
                                    child: Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xff186442),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        textDirection: TextDirection.ltr,
                                        children: [
                                          const SizedBox(width: 10),

                                          InkWell(
                                            onTap: () {
                                              widget.onNavigate?.call(1);
                                            },
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                              ),
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  'assets/icons/arrow_back.svg',
                                                  height: 12,
                                                  width: 16,
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: const [
                                                Text(
                                                  'خطط لعمرتك',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(height: 3),
                                                Text(
                                                  'احجز كل ما تحتاجه لرحلتك',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xffEFFAF3),
                                            ),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                'assets/icons/fa-solid_kaaba (1).svg',
                                                width: 24,
                                                height: 20,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            // =======================================
                            // GUIDE
                            // =======================================
                            InkWell(
                              onTap: () {
                                widget.onNavigate?.call(2);
                              },
                              child: AlDalilCard(),
                            ),

                            const SizedBox(height: 8),

                            // =======================================
                            // PACKAGES TITLE
                            // =======================================
                            Padding(
                              padding: const EdgeInsets.only(right: 26),
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  const Text('باقات و عروض'),

                                  const Spacer(),

                                  const Text(
                                    'عرض الكل ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),

                                  IconButton(
                                    icon: const Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Icon(
                                        Icons.arrow_back_ios_new,
                                        size: 12,
                                      ),
                                    ),
                                    color: Colors.black,
                                    onPressed: () {
                                      HelperFunction.navigate(
                                        context,
                                        BlocProvider.value(
                                          value: context.read<HomeBloc>(),
                                          child: Packagesscreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // =======================================
                            // PACKAGES
                            // =======================================
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: SizedBox(
                                  height: 175,
                                  child: BlocBuilder<HomeBloc, HomeState>(
                                    builder: (context, state) {
                                      // =============================
                                      // LOADING
                                      // =============================

                                      if (state is LoadingCategoryState) {
                                        return const Center(
                                          child: SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        );
                                      }

                                      // =============================
                                      // SUCCESS
                                      // =============================

                                      if (state is SuccessCategoryState) {
                                        if (state.data.isEmpty) {
                                          return const Center(
                                            child: Text('لا توجد باقات حالياً'),
                                          );
                                        }

                                        return ListView.separated(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          reverse: true,
                                          itemCount: state.data.length,
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(width: 8),
                                          itemBuilder: (context, index) {
                                            final package = state.data[index];

                                            return InkWell(
                                              onTap: () {
                                                HelperFunction.navigate(
                                                  context,
                                                  PackageDetailScreen(
                                                    package: package,
                                                  ),
                                                );
                                              },
                                              child: WidgetCard(
                                                image: package.imageUrl ?? '',
                                                title: package.name ?? '',
                                                subTitle:
                                                    package.extraServices ?? '',
                                                price: package.totalPrice ?? 0,
                                              ),
                                            );
                                          },
                                        );
                                      }

                                      // =============================
                                      // ERROR
                                      // =============================

                                      if (state is FailedCategoryState) {
                                        return Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.wifi_off_rounded,
                                                  size: 30,
                                                  color: Colors.grey.shade400,
                                                ),

                                                const SizedBox(height: 12),

                                                const Text(
                                                  'تعذر تحميل البيانات',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),

                                                const SizedBox(height: 5),

                                                Text(
                                                  'تأكد من اتصالك بالإنترنت ثم حاول مرة أخرى',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),

                                                const SizedBox(height: 8),

                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    context
                                                        .read<HomeBloc>()
                                                        .add(
                                                          GetHomeCategories(),
                                                        );
                                                  },
                                                  icon: const Icon(
                                                    Icons.refresh,
                                                  ),
                                                  label: const Text(
                                                    'إعادة المحاولة',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // =======================================
                            // SMART ASSISTANT
                            // =======================================
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const SmartAssistantScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xffEEF5F8),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.05),
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.05),
                                      offset: Offset(2, 0),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    SizedBox(
                                      width: 55,
                                      height: 55,
                                      child: SvgPicture.asset(
                                        'assets/icons/arcticons_chat-nektome (1).svg',
                                        fit: BoxFit.contain,
                                      ),
                                    ),

                                    const SizedBox(width: 15),

                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'هل لديك سؤال عن العمرة؟',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),

                                          const SizedBox(height: 8),

                                          const Text(
                                            'اسأل المساعد الذكي واحصل على الإجابة',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Color.fromRGBO(
                                                0,
                                                0,
                                                0,
                                                0.5,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 8),

                                          Container(
                                            width: 109,
                                            height: 28,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff186442),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                const Text(
                                                  'اسأل المساعد',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),

                                                const Spacer(),

                                                const Directionality(
                                                  textDirection:
                                                      TextDirection.ltr,
                                                  child: Icon(
                                                    Icons.arrow_back_ios,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 23),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
