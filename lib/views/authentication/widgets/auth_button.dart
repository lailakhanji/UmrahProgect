import 'package:flutter/material.dart';
import 'package:umrahapp/utils/helper_function.dart';
import 'package:umrahapp/views/authentication/auth_screen.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({super.key,required this.isForLogin,this.switchAuthStatus, this.onLoginOrCreateAccount});
final bool isForLogin;
final void Function()? switchAuthStatus;
  final void Function()? onLoginOrCreateAccount;
  @override
  Widget build(BuildContext context) {
    return Column(spacing: 24,
      children: [
        ElevatedButton(  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary,
    minimumSize: Size(MediaQuery.sizeOf(context).width-50, 36),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12)
    )),
            onPressed: (){
   if(onLoginOrCreateAccount!=null){
     onLoginOrCreateAccount!.call();
    return;
    }
HelperFunction.navigateAndReplaceScreen(context, AuthScreen(isForLogin: false));
            }, child: Text(isForLogin?"تسجيل دخول":"إنشاء حساب",
              style: Theme.of(context).textTheme.labelSmall,)),
        Row(spacing: 5,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isForLogin?" ليس لديك حساب ؟ ":" لديك حساب مسبق؟ ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500,),),
InkWell(
  onTap:(){if(switchAuthStatus!=null){
    switchAuthStatus!.call();
    return;
    }
    HelperFunction.navigateAndReplaceScreen(context, AuthScreen(isForLogin: true));
    },
    child: Text(isForLogin?"إنشاء حساب":"تسجيل دخول",style:TextStyle(color: Theme.of(context).colorScheme.primary,
    fontSize: 14,fontWeight: FontWeight.w500,
    decoration: TextDecoration.underline,
    decorationColor: Theme.of(context).colorScheme.primary)))
          ],
        )
      ],

    );
  }
}
