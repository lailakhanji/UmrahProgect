import 'package:flutter/material.dart';

import '../../../services/shared_preferances_service.dart';
import '../../../utils/helper_function.dart';
import '../auth_screen.dart';

class NextButton extends StatelessWidget {
  final bool isForLogin;
  final VoidCallback onPressed;
  final void Function()? switchAuthStatus;
  final void Function()? onLoginOrCreateAccount;

  const NextButton({
    super.key,
    required this.onPressed,
    required this.isForLogin,
    this.switchAuthStatus,
    this.onLoginOrCreateAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(MediaQuery.sizeOf(context).width - 50, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: Color.fromRGBO(24, 100, 66, 1),
                width: 1,
              ),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            'التالي',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(24, 100, 66, 1),
            ),
          ),
        ),
        SizedBox(height: 24),
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
