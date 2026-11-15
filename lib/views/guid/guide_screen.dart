import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../home_page/widgets/GuideProgressService.dart';
import 'data/guide_api_service.dart';
import 'guide_bloc/guide_bloc.dart';
import 'guide_detail_screen.dart';

class GuideScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const GuideScreen({super.key, this.onBack});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  Set<String> completedGuideIds = {};

  @override
  void initState() {
    super.initState();
    _loadCompletedGuides();
  }

  // =====================================================
  // LOAD COMPLETED GUIDES
  // =====================================================

  Future<void> _loadCompletedGuides() async {
    final savedIds = await GuideProgressService.getCompletedGuideIds();

    if (!mounted) return;

    setState(() {
      completedGuideIds = savedIds;
    });
  }

  // =====================================================
  // COMPLETE GUIDE
  // =====================================================

  Future<void> _completeGuide(String guideId) async {
    await GuideProgressService.markAsCompleted(guideId);

    if (!mounted) return;

    setState(() {
      completedGuideIds.add(guideId);
    });
  }

  // =====================================================
  // RESET GUIDE
  // =====================================================

  Future<void> _resetGuide() async {
    await GuideProgressService.resetProgress();

    if (!mounted) return;

    setState(() {
      completedGuideIds.clear();
    });
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GuideBloc(guideApiService: GuideApiService())..add(GetGuidesEvent()),
      child: _GuideView(
        completedGuideIds: completedGuideIds,
        onStepCompleted: _completeGuide,
        onReset: _resetGuide,
        onBack: widget.onBack,
      ),
    );
  }
}

// =====================================================
// GUIDE VIEW
// =====================================================

class _GuideView extends StatefulWidget {
  final Set<String> completedGuideIds;
  final Function(String guideId) onStepCompleted;
  final Future<void> Function() onReset;
  final VoidCallback? onBack;

  const _GuideView({
    required this.completedGuideIds,
    required this.onStepCompleted,
    required this.onReset,
    this.onBack,
  });

  @override
  State<_GuideView> createState() => _GuideViewState();
}

// =====================================================
// GUIDE VIEW STATE
// =====================================================

class _GuideViewState extends State<_GuideView>
    with SingleTickerProviderStateMixin {
  static const Color primaryGreen = Color(0xff186442);

  static const Color lightGreen = Color(0xffEEF6F2);

  static const Color textColor = Color(0xff1D2B2A);

  static const Color secondaryText = Color(0xff77807E);

  // =====================================================
  // CELEBRATION
  // =====================================================

  late AnimationController _celebrationController;

  bool _showCelebration = false;

  final Random _random = Random();

  late List<_CelebrationParticle> _particles;

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {
    super.initState();

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _particles = List.generate(70, (index) {
      const colors = [
        Color(0xff186442),
        Color(0xff2381BC),
        Color(0xffF4C542),
        Color(0xffE8A23A),
        Color(0xff7A9E8C),
      ];

      return _CelebrationParticle(
        x: _random.nextDouble(),
        delay: _random.nextDouble() * 0.35,
        size: 5 + _random.nextDouble() * 7,
        rotation: _random.nextDouble() * pi,
        color: colors[_random.nextInt(colors.length)],
      );
    });
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  // =====================================================
  // PLAY CELEBRATION
  // =====================================================

  void _playCelebration() {
    if (_showCelebration) return;

    setState(() {
      _showCelebration = true;
    });

    _celebrationController.reset();
    _celebrationController.forward();

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;

      setState(() {
        _showCelebration = false;
      });
    });
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9F8),
      body: SafeArea(
        child: BlocBuilder<GuideBloc, GuideState>(
          builder: (context, state) {
            // =================================================
            // LOADING
            // =================================================

            if (state is GuideLoading) {
              return const Center(
                child: CircularProgressIndicator(color: primaryGreen),
              );
            }

            // =================================================
            // ERROR
            // =================================================

            if (state is GuideFailure) {
              return const Center(
                child: Text(
                  'حدث خطأ أثناء تحميل الدليل',
                  style: TextStyle(fontSize: 15, color: textColor),
                ),
              );
            }

            // =================================================
            // SUCCESS
            // =================================================

            if (state is GuideSuccess) {
              final guides = [...state.guides];

              guides.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

              GuideProgressService.saveTotalSteps(guides.length);

              return _buildGuideContent(context, guides);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  // =====================================================
  // GUIDE CONTENT
  // =====================================================

  Widget _buildGuideContent(BuildContext context, List guides) {
    final totalSteps = guides.length;

    final completedCount = widget.completedGuideIds.length;

    final progress = totalSteps == 0 ? 0.0 : completedCount / totalSteps;

    return Stack(
      children: [
        // =================================================
        // MAIN CONTENT
        // =================================================
        CustomScrollView(
          physics: const BouncingScrollPhysics(),

          slivers: [
            // =============================================
            // HEADER
            // =============================================
            SliverToBoxAdapter(
              child: _buildHeader(completedCount, totalSteps, progress),
            ),

            // =============================================
            // SECTION TITLE
            // =============================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
                child: const Text(
                  'خطوات العمرة',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
            ),

            // =============================================
            // GUIDE STEPS
            // =============================================
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final guide = guides[index];

                  final isCompleted = widget.completedGuideIds.contains(
                    guide.id,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _GuideStepCard(
                      stepNumber: index + 1,
                      title: guide.title,
                      subtitle: _getStepDescription(index),
                      icon: _getStepIcon(index),
                      isCompleted: isCompleted,
                      onTap: () async {
                        final wasAlreadyCompleted = widget.completedGuideIds
                            .contains(guide.id);

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GuideDetailScreen(
                              guide: guide,
                              stepNumber: index + 1,
                              totalSteps: totalSteps,
                            ),
                          ),
                        );

                        if (result != true) {
                          return;
                        }

                        // حفظ الخطوة
                        await widget.onStepCompleted(guide.id);

                        // العدد الجديد بعد الإكمال
                        final newCompletedCount =
                            widget.completedGuideIds.length +
                            (wasAlreadyCompleted ? 0 : 1);

                        // الاحتفال فقط عند آخر خطوة
                        // الاحتفال فقط عند إكمال آخر خطوة فعلياً
                        if (!wasAlreadyCompleted && index == totalSteps - 1) {
                          _playCelebration();
                        }
                      },
                    ),
                  );
                }, childCount: guides.length),
              ),
            ),

            // =============================================
            // DUA CARD
            // =============================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: _buildDuaCard(),
              ),
            ),

            // =============================================
            // RESET BUTTON
            // =============================================
            if (widget.completedGuideIds.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                  child: _buildResetButton(),
                ),
              ),
          ],
        ),

        // =================================================
        // CELEBRATION OVERLAY
        // =================================================
        if (_showCelebration)
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  // =========================================
                  // CONFETTI
                  // =========================================
                  AnimatedBuilder(
                    animation: _celebrationController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size.infinite,
                        painter: _CelebrationPainter(
                          particles: _particles,
                          progress: _celebrationController.value,
                        ),
                      );
                    },
                  ),

                  // =========================================
                  // SUCCESS CARD
                  // =========================================
                  Center(
                    child: ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _celebrationController,
                        curve: Curves.elasticOut,
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 35),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 25,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ===========================
                            // CHECK ICON
                            // ===========================
                            Container(
                              width: 75,
                              height: 75,
                              decoration: const BoxDecoration(
                                color: Color(0xffEAF6EF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 42,
                                color: primaryGreen,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // ===========================
                            // TITLE
                            // ===========================
                            const Text(
                              'ما شاء الله! 🎉',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ===========================
                            // DESCRIPTION
                            // ===========================
                            const Text(
                              'لقد أكملت جميع خطوات العمرة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: secondaryText,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              'تقبل الله عمرتك 🤍',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader(int completedCount, int totalSteps, double progress) {
    return Column(
      children: [
        // =============================================
        // TOP HEADER
        // خارج البوكس
        // =============================================
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              // =========================================
              // BACK BUTTON
              // =========================================
              InkWell(
                onTap: () {
                  if (widget.onBack != null) {
                    widget.onBack!();
                  } else {
                    Navigator.pop(context);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              Spacer(),

              // =========================================
              // TITLE
              // =========================================
              const Text(
                'دليل العمرة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Spacer(),
            ],
          ),
        ),

        // =============================================
        // PROGRESS BOX
        // =============================================
        Text(
          'دليل بسيط يساعدك على معرفة خطوات العمرة خطوة بخطوة',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================================
              // PROGRESS TITLE
              // =========================================
              Row(
                children: [
                  const Text(
                    'التقدم',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    '$completedCount / $totalSteps',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryGreen,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // =========================================
              // PROGRESS BAR
              // =========================================
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: const Color(0xffE8EEEB),
                  valueColor: const AlwaysStoppedAnimation(primaryGreen),
                ),
              ),

              const SizedBox(height: 10),

              // =========================================
              // PROGRESS TEXT
              // =========================================
              Text(
                totalSteps == 0
                    ? 'ابدئي رحلتك مع دليل العمرة'
                    : completedCount == totalSteps
                    ? 'ما شاء الله، أكملتِ جميع الخطوات'
                    : 'أكملتِ $completedCount من أصل $totalSteps خطوات',
                style: const TextStyle(fontSize: 12, color: secondaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================================
  // DUA CARD
  // =====================================================

  Widget _buildDuaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xffF0F5F2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: Color(0xffC8D5CF))),
            ),
            child: const Icon(
              Icons.mosque_outlined,
              color: primaryGreen,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Text(
              'نسأل الله أن يجعل عمرتك سهلة ومقبولة.',
              style: TextStyle(fontSize: 13, height: 1.6, color: secondaryText),
            ),
          ),

          const Icon(
            Icons.auto_awesome_outlined,
            size: 20,
            color: primaryGreen,
          ),
        ],
      ),
    );
  }

  // =====================================================
  // RESET BUTTON
  // =====================================================

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () async {
          final shouldReset = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                title: const Text(
                  'إعادة المناسك',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: primaryGreen),
                ),
                content: const Text(
                  'هل تريد إعادة دليل العمرة من البداية؟\nسيتم حذف جميع الخطوات المكتملة.',
                  textAlign: TextAlign.right,
                ),
                actions: [
                  // ---------------------------------------
                  // CANCEL
                  // ---------------------------------------
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('إلغاء'),
                  ),

                  // ---------------------------------------
                  // RESET
                  // ---------------------------------------
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('إعادة'),
                  ),
                ],
              );
            },
          );

          if (shouldReset != true) {
            return;
          }

          // إخفاء الاحتفال
          _celebrationController.stop();
          _celebrationController.reset();

          if (mounted) {
            setState(() {
              _showCelebration = false;
            });
          }

          // إعادة الخطوات
          await widget.onReset();
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: primaryGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.restart_alt, color: primaryGreen),
        label: const Text(
          'إعادة المناسك من البداية',
          style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // =====================================================
  // STEP SVG ICON
  // =====================================================

  String _getStepIcon(int index) {
    switch (index) {
      case 0:
        return 'assets/icons/TShirt.svg';

      case 1:
        return 'assets/icons/Cube.svg';

      case 2:
        return 'assets/icons/Mountains.svg';

      case 3:
        return 'assets/icons/Scissors.svg';

      default:
        return 'assets/images/guide.svg';
    }
  }

  // =====================================================
  // STEP DESCRIPTION
  // =====================================================

  String _getStepDescription(int index) {
    switch (index) {
      case 0:
        return 'الدخول في حالة الإحرام.';

      case 1:
        return 'الطواف حول الكعبة المشرفة.';

      case 2:
        return 'السعي بين الصفا والمروة.';

      case 3:
        return 'إتمام آخر خطوة من العمرة.';

      default:
        return 'تعرف على هذه الخطوة من دليل العمرة.';
    }
  }
}

// =====================================================
// GUIDE STEP CARD
// =====================================================

class _GuideStepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final String icon;
  final bool isCompleted;
  final VoidCallback onTap;

  const _GuideStepCard({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
    required this.onTap,
  });

  static const Color primaryGreen = Color(0xff186442);

  static const Color textColor = Color(0xff1D2B2A);

  static const Color secondaryText = Color(0xff77807E);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 108,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isCompleted
                  ? primaryGreen.withOpacity(0.25)
                  : const Color(0xffE7EBE9),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // =========================================
              // STEP NUMBER
              // =========================================
              SizedBox(
                width: 66,
                child: Center(
                  child: Text(
                    stepNumber.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: isCompleted
                          ? primaryGreen
                          : const Color(0xff9AA5A1),
                    ),
                  ),
                ),
              ),

              // =========================================
              // VERTICAL LINE
              // =========================================
              Container(width: 1, height: 64, color: const Color(0xffE5E9E7)),

              // =========================================
              // SVG ICON
              // =========================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xffE8F3ED)
                        : const Color(0xffF4F6F5),
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: primaryGreen, size: 25)
                      : Padding(
                          padding: const EdgeInsets.all(11),
                          child: SvgPicture.asset(
                            icon,
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,

                            colorFilter: const ColorFilter.mode(
                              primaryGreen,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                ),
              ),

              // =========================================
              // TEXT
              // =========================================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 17, right: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.4,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // =========================================
              // STATUS / ARROW
              // =========================================
              SizedBox(
                width: 69,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // STATUS
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xffEEF8F2)
                            : const Color(0xffF6F7F7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle_outline
                                : Icons.radio_button_unchecked,
                            size: 11,
                            color: isCompleted ? primaryGreen : secondaryText,
                          ),

                          const SizedBox(width: 3),

                          Text(
                            isCompleted ? 'مكتمل' : 'ابدأ',
                            style: TextStyle(
                              fontSize: 8.5,
                              color: isCompleted ? primaryGreen : secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 13),

                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: secondaryText,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// CELEBRATION PARTICLE
// =====================================================

class _CelebrationParticle {
  final double x;
  final double delay;
  final double size;
  final double rotation;
  final Color color;

  _CelebrationParticle({
    required this.x,
    required this.delay,
    required this.size,
    required this.rotation,
    required this.color,
  });
}

// =====================================================
// CELEBRATION PAINTER
// =====================================================

class _CelebrationPainter extends CustomPainter {
  final List<_CelebrationParticle> particles;

  final double progress;

  _CelebrationPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final adjustedProgress =
          ((progress - particle.delay) / (1 - particle.delay)).clamp(0.0, 1.0);

      if (adjustedProgress <= 0) {
        continue;
      }

      // موقع العنصر
      final x = particle.x * size.width;

      final y = -30 + (size.height * 0.75 * adjustedProgress);

      // اختفاء تدريجي بالنهاية
      final opacity = progress > 0.80 ? (1 - progress) * 5 : 1.0;

      final paint = Paint()
        ..color = particle.color.withOpacity(opacity.clamp(0.0, 1.0));

      canvas.save();

      canvas.translate(x, y);

      canvas.rotate(particle.rotation + adjustedProgress * pi * 4);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 1.6,
          ),
          Radius.circular(particle.size / 2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
