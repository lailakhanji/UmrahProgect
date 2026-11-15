import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:umrahapp/views/profile/widget/edit_passport_bottom_sheet.dart';
import 'package:umrahapp/views/profile/widget/logout_bottom_sheet.dart';

import 'profile_bloc/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    print("PROFILE SCREEN INIT");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("SENDING GET PROFILE EVENT");

      context.read<ProfileBloc>().add(GetProfileEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // ================= APP BAR =================
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAFFFC),
          elevation: 0,
          centerTitle: true,

          title: const Text(
            'الملف الشخصي',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          iconTheme: const IconThemeData(color: Colors.black),
        ),

        // ================= BODY =================
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            // ================= LOADING =================
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF186442)),
              );
            }

            // ================= FAILURE =================
            if (state is ProfileFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 45,
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

                          const SizedBox(height: 8),

                          Text(
                            'تأكد من اتصالك بالإنترنت ثم حاول مرة أخرى',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 18),

                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<ProfileBloc>().add(
                                GetProfileEvent(),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            // ================= LOADED =================
            if (state is ProfileLoaded) {
              final profile = state.profile;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 25),

                    // ================= PERSONAL INFO TITLE =================
                    const Text(
                      'المعلومات الشخصية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ================= PERSONAL INFO CARD =================
                    _buildInfoCard(
                      children: [
                        _buildInfoRow(
                          title: 'الاسم',
                          value: profile.firstName,
                          icon: Icons.person_outline,
                        ),

                        _buildDivider(),
                        _buildInfoRow(
                          title: 'الكنية',
                          value: profile.lastName,
                          icon: Icons.person_outline,
                        ),

                        _buildDivider(),

                        _buildInfoRow(
                          title: 'رقم الهاتف',
                          value: profile.phone,
                          icon: Icons.phone_outlined,
                          isLtr: true,
                        ),

                        _buildDivider(),

                        _buildInfoRow(
                          title: 'تاريخ الميلاد',
                          value: _formatDate(profile.dateOfBirth),
                          icon: Icons.cake_outlined,
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ================= PASSPORT TITLE =================
                    // ================= PASSPORT TITLE =================
                    const Text(
                      'معلومات جواز السفر',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ================= PASSPORT CARD =================
                    _buildInfoCard(
                      children: [
                        _buildInfoRow(
                          title: 'رقم جواز السفر',
                          value: profile.passportNumber ?? 'غير محدد',
                          icon: Icons.badge_outlined,
                          isLtr: true,
                        ),

                        _buildDivider(),

                        _buildInfoRow(
                          title: 'تاريخ انتهاء صلاحية جواز السفر',
                          value: _formatDate(profile.passportExpiryDate),
                          icon: Icons.calendar_today_outlined,
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // ================= EDIT PASSPORT BUTTON =================
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (modalContext) => BlocProvider.value(
                              value: context.read<ProfileBloc>(),
                              // تمرير الـ Bloc الحالي للشيت
                              child: EditPassportBottomSheet(
                                currentPassportNumber:
                                    profile.passportNumber ?? '',
                                currentExpiryDate: profile.passportExpiryDate,
                              ),
                            ),
                          );
                        },

                        icon: SvgPicture.asset('assets/icons/lucide_edit.svg'),
                        label: const Text(
                          'تعديل ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Color(0xff186442),
                          side: const BorderSide(color: Color(0xFF186442)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ================= LOGOUT =================
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (modalContext) => BlocProvider.value(
                              value: context.read<ProfileBloc>(),
                              // 👈 تمرير الـ Bloc الحالي هنا
                              child: const LogoutBottomSheet(),
                            ),
                          );
                        },

                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'تسجيل الخروج',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFFDADA)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              );
            }

            // ================= INITIAL =================
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF186442)),
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // INFO CARD
  // =========================================================

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EDE9)),
      ),
      child: Column(children: children),
    );
  }

  // =========================================================
  // INFO ROW
  // =========================================================

  Widget _buildInfoRow({
    required String title,
    required String value,
    required IconData icon,
    bool isLtr = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // ICON
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF186442), size: 21),
          ),

          const SizedBox(width: 14),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DIVIDER
  // =========================================================

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFEDEDED));
  }

  // =========================================================
  // FORMAT DATE
  // =========================================================

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'غير محدد';
    }

    return '${date.day}/'
        '${date.month}/'
        '${date.year}';
  }

  // =========================================================
  // LOGOUT DIALOG
  // =========================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تسجيل الخروج'),

            content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  // سنضيف منطق تسجيل الخروج هنا
                },
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
