import 'package:flutter/material.dart';
import 'package:umrahapp/services/shared_preferances_service.dart';
import 'package:umrahapp/utils/helper_function.dart';
import 'package:umrahapp/views/authentication/auth_screen.dart';

class AuthButton extends StatelessWidget {
  final bool isLoading;
  final bool isForLogin;
  final void Function()? switchAuthStatus;
  final void Function()? onLoginOrCreateAccount;

  const AuthButton({
    super.key,
    required this.isForLogin,
    this.switchAuthStatus,
    this.onLoginOrCreateAccount,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 24,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(MediaQuery.of(context).size.width - 40, 40),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: isLoading
              ? null
              : () {
                  onLoginOrCreateAccount?.call();
                },
          child: Text(
            isForLogin ? "تسجيل دخول" : "إنشاء حساب",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Row(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isForLogin ? " ليس لديك حساب ؟ " : " لديك حساب مسبق؟ ",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            InkWell(
              onTap: () {
                if (switchAuthStatus != null) {
                  switchAuthStatus!.call();
                  return;
                }
                SharedPreferancesService.isTheOnBoardingScreenSeen = true;
                HelperFunction.navigateAndReplaceScreen(
                  context,
                  AuthScreen(isForLogin: true),
                );
              },
              child: Text(
                isForLogin ? "إنشاء حساب" : "تسجيل دخول",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                  decorationColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
