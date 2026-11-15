import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umrahapp/constants/my_assets_url.dart';
import 'package:umrahapp/utils/helper_function.dart';
import 'package:umrahapp/views/authentication/auth_bloc/auth_bloc.dart';
import 'package:umrahapp/views/authentication/widgets/auth_button.dart';
import 'package:umrahapp/views/authentication/widgets/auth_input_field.dart';
import 'package:umrahapp/views/home_page/bottom_navigation_bar_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool isForLogin;

  const AuthScreen({super.key, required this.isForLogin});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // =========================================================
  // CONTROLLERS
  // =========================================================

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController passportController = TextEditingController();

  final TextEditingController passportExpiryController =
      TextEditingController();

  final TextEditingController birthDateController = TextEditingController();
  String? emailApiError;

  // =========================================================
  // STATE
  // =========================================================

  late bool isLogin;

  int currentStep = 1;

  // =========================================================
  // REGEX
  // =========================================================

  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$&*~]).{8,}$',
  );

  final RegExp phoneRegex = RegExp(r'^09[345689][0-9]{7}$');

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    isLogin = widget.isForLogin;
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();

    passportController.dispose();
    passportExpiryController.dispose();
    birthDateController.dispose();

    super.dispose();
  }

  // =========================================================
  // AGE
  // =========================================================

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();

    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final isKeyboardVisible = bottomInset > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: Directionality(
        textDirection: TextDirection.rtl,

        child: Stack(
          children: [
            // =================================================
            // BACKGROUND
            // =================================================
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Image.asset(
                  MyAssetsUrl.loginBackgroungHeadImage,
                  width: MediaQuery.sizeOf(context).width,
                  fit: BoxFit.fitWidth,
                ),

                Image.asset(
                  MyAssetsUrl.loginBackgroungtrailImage,
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height * 0.09,
                  fit: BoxFit.fitHeight,
                ),
              ],
            ),

            // =================================================
            // CONTENT
            // =================================================
            SafeArea(
              child: Form(
                key: formKey,

                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),

                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: bottomInset + (isKeyboardVisible ? 20 : 120),
                  ),

                  child: Column(
                    children: [
                      const SizedBox(height: 150),

                      Text(
                        isLogin ? "تسجيل دخول" : "إنشاء حساب",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),

                      const SizedBox(height: 30),

                      if (isLogin)
                        _loginFields()
                      else if (currentStep == 1)
                        _registerStepOne()
                      else
                        _registerStepTwo(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // REGISTER STEP ONE
  // =========================================================

  Widget _registerStepOne() {
    return Column(
      children: [
        // =====================================================
        // FIRST + LAST NAME
        // =====================================================
        Row(
          children: [
            Expanded(
              child: AuthInputField(
                controller: firstNameController,
                hintText: "الاسم",
                prefixIcon: Icons.person_outline,

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "الرجاء إدخال الاسم";
                  }

                  if (value.trim().length < 2) {
                    return "الاسم غير صالح";
                  }

                  return null;
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: AuthInputField(
                controller: lastNameController,
                hintText: "الكنية",
                prefixIcon: Icons.person_outline,

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "الرجاء إدخال الكنية";
                  }

                  if (value.trim().length < 2) {
                    return "الكنية غير صالحة";
                  }

                  return null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // =====================================================
        // PHONE
        // =====================================================
        AuthInputField(
          controller: phoneController,
          hintText: "رقم الهاتف",
          prefixIcon: Icons.phone_outlined,
          phone: true,

          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "الرجاء إدخال رقم الهاتف";
            }

            if (!phoneRegex.hasMatch(value.trim())) {
              return "رقم الهاتف غير صالح";
            }

            return null;
          },
        ),

        const SizedBox(height: 10),

        // =====================================================
        // EMAIL
        // =====================================================
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return AuthInputField(
              controller: emailController,

              errorText: emailApiError,

              hintText: "البريد الإلكتروني",
              prefixIcon: Icons.email_outlined,
              isEmail: true,

              onChanged: (_) {
                // بمجرد أن تبدأ بتعديل الإيميل
                // نمسح خطأ الحساب القديم
                if (emailApiError != null) {
                  setState(() {
                    emailApiError = null;
                  });
                }

                context.read<AuthBloc>().add(ClearAuthErrorEvent());
              },

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "الرجاء إدخال البريد الإلكتروني";
                }

                if (!emailRegex.hasMatch(value.trim())) {
                  return "البريد الإلكتروني غير صالح";
                }

                return null;
              },
            );
          },
        ),

        const SizedBox(height: 10),

        // =====================================================
        // PASSWORD
        // =====================================================
        AuthInputField(
          controller: passwordController,
          hintText: "كلمة المرور",
          prefixIcon: Icons.key_outlined,
          sufixIcon: Icons.remove_red_eye_outlined,

          validator: (value) {
            if (value == null || value.isEmpty) {
              return "الرجاء إدخال كلمة المرور";
            }

            if (!passwordRegex.hasMatch(value)) {
              return "يجب أن تحتوي كلمة المرور على 8 محارف على الأقل، وحرف كبير وصغير ورقم ورمز";
            }

            return null;
          },
        ),

        const SizedBox(height: 10),

        // =====================================================
        // CONFIRM PASSWORD
        // =====================================================
        AuthInputField(
          controller: confirmPasswordController,
          hintText: "تأكيد كلمة المرور",
          prefixIcon: Icons.key_outlined,
          sufixIcon: Icons.remove_red_eye_outlined,

          validator: (value) {
            if (value == null || value.isEmpty) {
              return "الرجاء تأكيد كلمة المرور";
            }

            if (value != passwordController.text) {
              return "كلمة المرور غير متطابقة";
            }

            return null;
          },
        ),

        const SizedBox(height: 55),

        // =====================================================
        // NEXT
        // =====================================================
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(MediaQuery.sizeOf(context).width - 50, 36),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),

              side: const BorderSide(color: Color.fromRGBO(24, 100, 66, 1)),
            ),
          ),

          onPressed: () {
            if (!formKey.currentState!.validate()) {
              return;
            }

            context.read<AuthBloc>().add(ClearAuthErrorEvent());

            setState(() {
              currentStep = 2;
            });
          },

          child: const Text(
            "التالي",
            style: TextStyle(
              color: Color.fromRGBO(24, 100, 66, 1),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // =====================================================
        // LOGIN
        // =====================================================
        Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Text("لديك حساب مسبق؟ ", style: TextStyle(fontSize: 12)),

            InkWell(
              onTap: _switchToLogin,

              child: Text(
                "تسجيل دخول",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,

                  fontSize: 14,

                  fontWeight: FontWeight.w500,

                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // REGISTER STEP TWO
  // =========================================================

  Widget _registerStepTwo() {
    return Column(
      children: [
        // =====================================================
        // API ERROR
        // =====================================================
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthFailed &&
                state.message != null &&
                state.message!.isNotEmpty) {
              return Container(
                width: double.infinity,

                margin: const EdgeInsets.only(bottom: 12),

                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.message!,
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(ClearAuthErrorEvent());
                      },

                      icon: Icon(
                        Icons.close,
                        color: Colors.red.shade700,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),

        // =====================================================
        // BIRTH DATE
        // =====================================================
        GestureDetector(
          onTap: () {
            _selectBirthDate(context);
          },

          child: AbsorbPointer(
            child: AuthInputField(
              controller: birthDateController,

              hintText: "تاريخ الميلاد",

              prefixIcon: Icons.calendar_month_outlined,

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "الرجاء إدخال تاريخ الميلاد";
                }

                final birthDate = DateTime.tryParse(value);

                if (birthDate == null) {
                  return "تاريخ الميلاد غير صالح";
                }

                final age = _calculateAge(birthDate);

                if (age < 12) {
                  return "يجب أن يكون العمر 12 سنة أو أكثر";
                }

                return null;
              },
            ),
          ),
        ),

        const SizedBox(height: 10),

        // =====================================================
        // PASSPORT
        // =====================================================
        AuthInputField(
          controller: passportController,
          hintText: "رقم الجواز",
          prefixIcon: Icons.badge_outlined,
          phone: true,

          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "الرجاء إدخال رقم الجواز";
            }

            if (value.trim().length < 6) {
              return "رقم الجواز غير صالح";
            }

            return null;
          },
        ),

        const SizedBox(height: 10),

        // =====================================================
        // PASSPORT EXPIRY
        // =====================================================
        GestureDetector(
          onTap: () {
            _selectExpiryDate(context);
          },

          child: AbsorbPointer(
            child: AuthInputField(
              controller: passportExpiryController,

              hintText: "تاريخ انتهاء الجواز",

              prefixIcon: Icons.calendar_month_outlined,

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "الرجاء إدخال تاريخ انتهاء الجواز";
                }

                final expiryDate = DateTime.tryParse(value);

                if (expiryDate == null) {
                  return "تاريخ انتهاء الجواز غير صالح";
                }

                final today = DateTime.now();

                final todayOnly = DateTime(today.year, today.month, today.day);

                final expiryOnly = DateTime(
                  expiryDate.year,
                  expiryDate.month,
                  expiryDate.day,
                );

                if (expiryOnly.isBefore(todayOnly)) {
                  return "تاريخ انتهاء الجواز منتهي";
                }

                return null;
              },
            ),
          ),
        ),

        const SizedBox(height: 70),

        // =====================================================
        // REGISTER BUTTON
        // =====================================================
        BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              setState(() {
                emailApiError = null;
              });

              _clearFields();

              HelperFunction.navigateAndReplaceScreen(
                context,
                BottomNavigationBarScreen(),
              );
            }

            if (state is AuthFailed) {
              setState(() {
                emailApiError = state.message;
              });


              setState(() {
                currentStep = 1;
              });
            }
          },

          builder: (context, state) {
            return AuthButton(
              isForLogin: false,
              isLoading: state is AuthLoading,
              onLoginOrCreateAccount: _register,
              switchAuthStatus: _switchToLogin,
            );
          },
        ),

        const SizedBox(height: 16),

        // =====================================================
        // BACK
        // =====================================================
        Directionality(
          textDirection: TextDirection.ltr,

          child: TextButton.icon(
            onPressed: () {
              context.read<AuthBloc>().add(ClearAuthErrorEvent());

              setState(() {
                currentStep = 1;
              });
            },

            icon: const Icon(Icons.arrow_back),

            label: const Text("السابق"),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // LOGIN FIELDS
  // =========================================================

  Widget _loginFields() {
    return Column(
      children: [
        // =====================================================
        // EMAIL
        // =====================================================
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String? apiError;

            if (state is AuthFailed) {
              apiError = state.message;
            }

            return AuthInputField(
              controller: emailController,

              hintText: "البريد الإلكتروني",

              prefixIcon: Icons.email_outlined,

              isEmail: true,

              errorText: apiError,

              onChanged: (_) {
                context.read<AuthBloc>().add(ClearAuthErrorEvent());
              },

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "الرجاء إدخال البريد الإلكتروني";
                }

                if (!emailRegex.hasMatch(value.trim())) {
                  return "البريد الإلكتروني غير صالح";
                }

                return null;
              },
            );
          },
        ),

        const SizedBox(height: 16),

        // =====================================================
        // PASSWORD
        // =====================================================
        AuthInputField(
          controller: passwordController,

          hintText: "كلمة المرور",

          prefixIcon: Icons.key_outlined,

          sufixIcon: Icons.remove_red_eye_outlined,

          obscure: true,

          validator: (value) {
            if (value == null || value.isEmpty) {
              return "الرجاء إدخال كلمة المرور";
            }

            return null;
          },
        ),

        const SizedBox(height: 30),

        // =====================================================
        // LOGIN BUTTON
        // =====================================================
        BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              HelperFunction.navigateAndReplaceScreen(
                context,
                BottomNavigationBarScreen(),
              );
            }
          },

          builder: (context, state) {
            return Column(
              children: [
                const SizedBox(height: 30),

                AuthButton(
                  isForLogin: true,

                  isLoading: state is AuthLoading,

                  onLoginOrCreateAccount: _login,

                  switchAuthStatus: _switchToRegister,
                ),

                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ],
    );
  }

  // =========================================================
  // REGISTER
  // =========================================================

  void _register() {
    context.read<AuthBloc>().add(ClearAuthErrorEvent());

    final isValid = formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    context.read<AuthBloc>().add(
      RegisterEvent(
        email: emailController.text.trim(),

        password: passwordController.text,

        confirmPassword: confirmPasswordController.text,

        firstName: firstNameController.text.trim(),

        lastName: lastNameController.text.trim(),

        phone: phoneController.text.trim(),

        passportNumber: passportController.text.trim(),

        passportExpiryDate: passportExpiryController.text,

        dateOfBirth: birthDateController.text,
      ),
    );
  }

  // =========================================================
  // LOGIN
  // =========================================================

  void _login() {
    context.read<AuthBloc>().add(ClearAuthErrorEvent());

    final isValid = formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    context.read<AuthBloc>().add(
      LoginEvent(emailController.text.trim(), passwordController.text),
    );
  }

  // =========================================================
  // SWITCH TO LOGIN
  // =========================================================

  void _switchToLogin() {
    context.read<AuthBloc>().add(ClearAuthErrorEvent());

    setState(() {
      isLogin = true;
      currentStep = 1;
    });
  }

  // =========================================================
  // SWITCH TO REGISTER
  // =========================================================

  void _switchToRegister() {
    context.read<AuthBloc>().add(ClearAuthErrorEvent());

    setState(() {
      isLogin = false;
      currentStep = 1;
    });
  }

  // =========================================================
  // CLEAR FIELDS
  // =========================================================

  void _clearFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    firstNameController.clear();
    lastNameController.clear();
    phoneController.clear();

    passportController.clear();
    passportExpiryController.clear();
    birthDateController.clear();
  }

  // =========================================================
  // BIRTH DATE PICKER
  // =========================================================

  Future<void> _selectBirthDate(BuildContext context) async {
    final now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,

      initialDate: DateTime(now.year - 12, now.month, now.day),

      firstDate: DateTime(1900),

      lastDate: DateTime(now.year - 12, now.month, now.day),

      initialDatePickerMode: DatePickerMode.year,

      locale: const Locale('ar', 'AE'),

      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(148, 200, 177, 1),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromRGBO(148, 200, 177, 1),
              ),
            ),
          ),

          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        birthDateController.text =
            "${pickedDate.year}-"
            "${pickedDate.month.toString().padLeft(2, '0')}-"
            "${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // =========================================================
  // PASSPORT EXPIRY PICKER
  // =========================================================

  Future<void> _selectExpiryDate(BuildContext context) async {
    final now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,

      initialDate: now.add(const Duration(days: 365)),

      firstDate: now,

      lastDate: DateTime(now.year + 20),

      initialDatePickerMode: DatePickerMode.year,

      locale: const Locale('ar', 'AE'),

      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(148, 200, 177, 1),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromRGBO(148, 200, 177, 1),
              ),
            ),
          ),

          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        passportExpiryController.text =
            "${pickedDate.year}-"
            "${pickedDate.month.toString().padLeft(2, '0')}-"
            "${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }
}
