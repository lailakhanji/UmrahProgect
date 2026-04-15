import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:umrahapp/constants/my_assets_url.dart';
import 'package:umrahapp/utils/display_messages.dart';
import 'package:umrahapp/utils/helper_function.dart';
import 'package:umrahapp/views/authentication/auth_bloc/auth_bloc.dart';
import 'package:umrahapp/views/authentication/widgets/auth_button.dart';
import 'package:umrahapp/views/authentication/widgets/auth_input_field.dart';
import 'package:umrahapp/views/home_screen.dart';

class AuthScreen extends StatefulWidget {
  final bool isForLogin;

  const AuthScreen({super.key, required this.isForLogin});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final ValueNotifier<bool> isLogin;
  final TextEditingController emailController=TextEditingController();
  final TextEditingController passwordController=TextEditingController();
  final TextEditingController confirmPasswordController=TextEditingController();
  final TextEditingController firstNameController=TextEditingController();
  final TextEditingController lastNameController=TextEditingController();
  final TextEditingController numberController=TextEditingController();
  final GlobalKey<FormState> formKey=GlobalKey<FormState>();
  final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  @override
  void initState() {
    isLogin=ValueNotifier(widget.isForLogin);

    super.initState();
  }
  @override
  void dispose() {
    isLogin.dispose();
    emailController.dispose() ;
    numberController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    confirmPasswordController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [

            Positioned(
              top: 0,
              child: Image.asset(
                MyAssetsUrl.loginBackgroungHeadImage,
                width: MediaQuery.sizeOf(context).width,
                fit: BoxFit.fitWidth,
              ),
            ),


            Positioned(
              bottom: 0,
              child: Image.asset(
                MyAssetsUrl.loginBackgroungtrailImage,
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height * 0.09,
                fit: BoxFit.fitHeight,
              ),
            ),


            SafeArea(
              child: Form(key: formKey,
                child: Column(
                  children: [
                    SizedBox(height: 140),

                    ValueListenableBuilder(
                      valueListenable: isLogin,
                      builder: (context, login, _) {
                        return Text(
                          login ? "تسجيل دخول" : "إنشاء حساب",
                          style: Theme.of(context).textTheme.headlineLarge,
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    /// الفورم (scroll)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 23, vertical: 20),
                          child: ValueListenableBuilder(
                            valueListenable: isLogin,
                            builder: (context, login, child) {
                              return Column(
                                spacing: 16,
                                children: [
                                  if (!login) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AuthInputField(
                                            controller: firstNameController,
                                            hintText: "الاسم",
                                            prefixIcon:
                                            Icons.person_outline,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: AuthInputField(
                                            controller: lastNameController,
                                            hintText: "الكنية",
                                            prefixIcon:
                                            Icons.person_outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                    AuthInputField(
                                      controller: numberController,
                                      hintText: "رقم الهاتف",
                                      prefixIcon:
                                      Icons.phone_outlined,
                        
                                    ),
                                  ],
                        
                                  child!,
                        
                                  if (!login)
                                    AuthInputField(
                                      controller:
                                      confirmPasswordController,
                                      hintText:
                                      "تأكيد كلمة المرور",
                                      prefixIcon: Icons.key_outlined,
                                      sufixIcon: Icons
                                          .remove_red_eye_outlined,
                                      obscure: true,
                                      validator: (value){
                                        if(value==null){
                                          return null;
                                        }
                                        if(value.length<8)return'كلمة المرور يجب أن تكون على الأقل 8 أحرف';
                                        return null;
                                      },
                                    ),
                                  /// زر
                        
                                  SizedBox(height: 20,),
                        
                                ],
                              );
                            },
                            child: Column(
                        
                              children: [
                                AuthInputField(
                                  controller: emailController,
                                  hintText:
                                  "البريد الالكتروني",
                                  prefixIcon:
                                  Icons.email_outlined,
                                    validator: (value) {
                                      if (value == null) return null;
                                      if (!emailRegex.hasMatch(value)) {
                                        return 'البريد غير صالح للاستخدام';
                                      }
                                      return null;
                                  }
                                ),
                                SizedBox(height: 16,),
                                AuthInputField(
                                  controller:
                                  passwordController,
                                  hintText: "كلمة المرور",
                                  prefixIcon:
                                  Icons.key_outlined,
                                  sufixIcon: Icons
                                      .remove_red_eye_outlined,
                                  obscure: true,
                                  validator: (value){
                                    if(value==null){
                                      return null;
                                    }
                                    if(value.length<8)return'كلمة المرور يجب أن تكون على الأقل 8 أحرف';
                                 return null;
                                  },
                        
                                ),
                                ValueListenableBuilder( valueListenable: isLogin,
                                    builder: (context, login, child)
                                { return Column(children: [ if(login)...{SizedBox(height: 50,),
                                  Row(spacing: 10, mainAxisAlignment: MainAxisAlignment.center,
                                    children: [ Container( height: 1, width: MediaQuery .sizeOf(context) .width / 2 - 40, color: Colors.grey, ), Text("أو"), Container( height: 1, width: MediaQuery .sizeOf(context) .width / 2 - 40, color: Colors.grey, ) ],),
                                  SizedBox(height: 30,), Row(spacing: 65, mainAxisAlignment: MainAxisAlignment.center, children: [SvgPicture.asset( "assets/icons/facebook_icon.svg", height: 46, width: 46,), SvgPicture.asset( "assets/icons/googole_icon.svg", height: 46, width: 46,), ],), SizedBox(height: 20,)} ],); } ),
                        
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthSuccess) {
                          HelperFunction.navigateAndReplaceScreen(context, HomeScreen());
                        }

                        if (state is AuthFailed) {
                          String displayMessage = "حدث خطأ غير متوقع، يرجى المحاولة لاحقاً"; // رسالة افتراضية

                          // فحص إذا كانت الرسالة تحتوي على خطأ 400 (Bad Request)
                          if (state.message.contains("400")) {
                            displayMessage = "البيانات المدخلة غير صحيحة، تأكد من ملء جميع الحقول بشكل سليم";
                          }
                          // فحص إذا كان هناك خطأ في الاتصال بالإنترنت
                          else if (state.message.contains("SocketException") || state.message.contains("connection")) {
                            displayMessage = "تعذر الاتصال بالسيرفر، تأكد من اتصال الإنترنت";
                          }
                          // إذا كان السيرفر يرسل رسالة معينة داخل الـ Body (وهذا سبب ظهور النص الطويل)
                          else if (state.message.contains("DioException")) {
                            displayMessage = "خطأ في عملية التسجيل، يرجى التأكد من صحة البيانات";
                          }

                          // إظهار الرسالة العربية المختصرة فقط
                          ShowMessage(context, message: displayMessage);
                        }



                      },
                      builder: (context, state) {
                        if (state is AuthLoading) {

                        }

                        return const SizedBox(); //
                      },
                    ),

                    ValueListenableBuilder(
                      valueListenable: isLogin,
                      builder: (context, login, _) {
                        return AuthButton(
                            isForLogin: login,
                            switchAuthStatus: () {
                              isLogin.value = !isLogin.value;
                            },
                            onLoginOrCreateAccount: _onLoginOrCreateAccount
                        );
                      },
                    ),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  _onLoginOrCreateAccount()async{
if(formKey.currentState!.validate())
  {
    if(!(await HelperFunction.hasInternetConnection())){
      return ShowMessage(context,message: 'لا يوجد اتصال بالانترنت');
    }
    bool isForLogin=isLogin.value;
if(!isForLogin)
  {
    if(confirmPasswordController.text!=passwordController.text)
      {
        return ShowMessage(context,message: 'كلمة المرور غير متطابقة');
      }
  }
if(isForLogin){
  BlocProvider.of<AuthBloc>(context).add(LoginEvent(emailController.text, passwordController.text));
}
  else{
  BlocProvider.of<AuthBloc>(context).add(RegisterEvent(emailController.text, passwordController.text, confirmPasswordController.text, numberController.text, firstNameController.text, lastNameController.text));
  }
    }
  }

}